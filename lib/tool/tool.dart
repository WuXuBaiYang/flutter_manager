import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/widget/dialog/image_editor.dart';
import 'package:open_dir/open_dir.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'date.dart';
import 'file.dart';
import 'log.dart';

/*
* 工具方法
* @author wuxubaiyang
* @Time 2022/9/8 15:09
*/
class Tool {
  // 生成id
  static String genID({int? seed}) {
    final time = DateTime.now().millisecondsSinceEpoch;
    return md5('${time}_${Random(seed ?? time).nextDouble()}');
  }

  // 生成时间戳签名
  static String genDateSign() => DateTime.now().format(DatePattern.dateSign);

  // 获取屏幕宽度
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // 获取屏幕高度
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  // 获取版本号
  static Future<String> get buildNumber async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  // 获取版本名
  static Future<String> get version async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // 解析字符串格式的色值
  static Color parseColor(String colorString,
      [Color defaultColor = Colors.white]) {
    try {
      if (colorString.isEmpty) return defaultColor;
      // 解析16进制格式的色值 0xffffff
      if (colorString.contains(RegExp(r'#|0x'))) {
        String hexColor = colorString.replaceAll(RegExp(r'#|0x'), '');
        if (hexColor.length == 6) hexColor = 'ff$hexColor';
        return Color(int.parse(hexColor, radix: 16));
      }
      // 解析rgb格式的色值 rgb(0,0,0)
      if (colorString.toLowerCase().contains(RegExp(r'rgb(.*)'))) {
        String valuesString = colorString.substring(4, colorString.length - 1);
        List<String> values = valuesString.split(',');
        if (values.length == 3) {
          int red = int.parse(values[0].trim());
          int green = int.parse(values[1].trim());
          int blue = int.parse(values[2].trim());
          return Color.fromARGB(255, red, green, blue);
        }
        return defaultColor;
      }
    } catch (e) {
      LogTool.e('色值格式化失败', error: e);
    }
    return defaultColor;
  }

  // 获取零点时间戳
  static DateTime getDayZero({int dayOffset = 0}) {
    if (dayOffset < 0) return DateTime.now();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: dayOffset));
  }

  // 获取距离零点的duration
  static Duration toDayZeroDuration({int dayOffset = 1}) {
    if (dayOffset < 1) return Duration.zero;
    return getDayZero(dayOffset: dayOffset).difference(DateTime.now());
  }

  // 打开本地目录
  static Future<bool?> openLocalPath(String? path) async {
    if (path?.isEmpty ?? true) return false;
    return OpenDir().openNativeDir(path: path!);
  }

  // 缓存目标文件到缓存目录
  static Future<String?> cacheFile(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) return null;
    final baseDir = await getFileCachePath();
    if (baseDir == null) return null;
    final outputPath = join(baseDir, '${Tool.genID()}${file.suffixes}');
    return (await file.copy(outputPath)).path;
  }

  // 获取文件缓存目录
  static Future<String?> getFileCachePath() =>
      FileTool.getDirPath(Common.cacheFilePath,
          root: FileDir.applicationDocuments);

  // 选择文件集合
  static Future<List<String>> pickFiles(
      {String? dialogTitle,
      String? initialDirectory,
      FileType type = FileType.any}) async {
    if (kIsWeb) return [];
    final result = await FilePicker.platform.pickFiles(
      type: type,
      lockParentWindow: true,
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
    );
    if (result == null || result.files.isEmpty) return [];
    return result.files.map((e) => e.path!).toList();
  }

  // 选择单文件
  static Future<String?> pickFile(
      {String? dialogTitle,
      String? initialDirectory,
      FileType type = FileType.any}) async {
    final result = await pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
    );
    return result.firstOrNull;
  }

  // 选择图片集合
  static Future<List<String>> pickImages(
      {String? dialogTitle, String? initialDirectory}) {
    return pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: FileType.image,
    );
  }

  // 选择单文件
  static Future<String?> pickImage(
      {String? dialogTitle, String? initialDirectory}) {
    return pickFile(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: FileType.image,
    );
  }

  // 选择图片并编辑
  static Future<String?> pickImageWithEdit(
    BuildContext context, {
    String? dialogTitle,
    String? initialDirectory,
    CropAspectRatio? absoluteRatio,
  }) async {
    return pickImage(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
    ).then((result) async {
      if (result?.isEmpty ?? true) return null;
      return editImage(context, result!, absoluteRatio: absoluteRatio);
    });
  }

  // 图片编辑
  static Future<String?> editImage(BuildContext context, String imagePath,
      {CropAspectRatio? absoluteRatio}) {
    return showImageEditor(context,
        path: imagePath, absoluteRatio: absoluteRatio);
  }

  // 选择目录
  static Future<String?> pickDirectory(
      {String? dialogTitle, String? initialDirectory}) async {
    return FilePicker.platform
        .getDirectoryPath(lockParentWindow: true, dialogTitle: dialogTitle);
  }
}

// 计算md5
String md5(String value) => crypto.md5.convert(utf8.encode(value)).toString();

// 区间计算
T range<T extends num>(T value, T begin, T end) => max(begin, min(end, value));

// 扩展集合
extension ListExtension<T> on List<T> {
  // 交换集合中两个位置的元素
  List<T> swap(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return this;
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final T item = removeAt(oldIndex);
    insert(newIndex, item);
    return this;
  }
}

// 扩展字符串
extension StringExtension on String {
  // 正则匹配第一个分组
  String regFirstGroup(String source, [int index = 0, bool trim = true]) {
    final match = RegExp(source).firstMatch(this);
    final result = match?.group(index) ?? '';
    if (!trim) return result;
    return result.trim();
  }
}
