import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_manager/gen/assets.gen.dart';
import 'package:flutter_manager/tool/image.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:xml/xml.dart';

// 平台基本信息元组
typedef PlatformInfo<T extends Record> = ({
  String path,
  String label,
  String package,
  List<PlatformLogo> logos,
  List<PlatformPermission> permissions,
  T info,
});

// 平台图标信息元组
typedef PlatformLogo = ({String name, String path, Size size});

// 平台权限信息元组
typedef PlatformPermission = ({
  String name,
  String desc,
  String value,
  String input,
});

// 扩展平台权限信息元组
extension PlatformPermissionExtension on PlatformPermission {
  // 根据条件搜索判断是否符合要求
  bool search(String keyword) {
    if (keyword.isEmpty) return true;
    return name.contains(keyword) ||
        desc.contains(keyword) ||
        value.contains(keyword);
  }

  // 实现copyWith
  PlatformPermission copyWith(
          {String? name, String? desc, String? value, String? input}) =>
      (
        name: name ?? this.name,
        desc: desc ?? this.desc,
        value: value ?? this.value,
        input: input ?? this.input,
      );
}

/*
* 平台工具抽象类
* @author wuxubaiyang
* @Time 2023/11/29 18:37
*/
abstract class PlatformTool<T extends Record> with PlatformToolMixin<T> {
  // 平台文件夹路径
  PlatformType get platform;

  // 判断当前平台路径是否可用
  bool isPathAvailable(String projectPath);

  // 获取平台路径
  String getPlatformPath(String projectPath) =>
      join(projectPath, platform.name);

  // 获取平台文件路径
  String getPlatformFilePath(String projectPath, String filePath) =>
      join(getPlatformPath(projectPath), filePath);

  // 读取平台文件内容（字符串）
  Future<String> readPlatformFile(String projectPath, String filePath) {
    final file = File(getPlatformFilePath(projectPath, filePath));
    return file.readAsString();
  }

  // 读取平台文件内容（json）
  Future<Map> readPlatformFileJson(String projectPath, String filePath) async {
    final content = await readPlatformFile(projectPath, filePath);
    return jsonDecode(content);
  }

  // 读取平台文件内容（xml）
  Future<XmlDocument> readPlatformFileXml(
      String projectPath, String filePath) async {
    final content = await readPlatformFile(projectPath, filePath);
    return XmlDocument.parse(content);
  }

  // 读取平台文件内容（xmlFragment）
  Future<XmlDocumentFragment> readPlatformFileXmlFragment(
      String projectPath, String filePath) async {
    final content = await readPlatformFile(projectPath, filePath);
    return XmlDocumentFragment.parse(content);
  }

  // 文件写入前自动备份(在目标文件目录中创建.bak文件)
  Future<void> autoBackup(String projectPath, String filePath) async {
    final file = File(getPlatformFilePath(projectPath, filePath));
    final bakFile = File('${file.path}.bak');
    if (!bakFile.existsSync() && file.existsSync()) {
      await file.copy(bakFile.path);
    }
  }

  // 恢复备份文件
  Future<void> restoreBackup(String projectPath, String filePath) async {
    final file = File(getPlatformFilePath(projectPath, filePath));
    final bakFile = File('${file.path}.bak');
    if (bakFile.existsSync()) {
      await bakFile.copy(file.path);
      await bakFile.delete();
    }
  }

  // 写入平台文件内容（字符串）
  Future<bool> writePlatformFile(
      String projectPath, String filePath, String content) async {
    try {
      final file = File(getPlatformFilePath(projectPath, filePath));
      await autoBackup(projectPath, filePath);
      await file.writeAsString(content);
      return true;
    } catch (_) {}
    return false;
  }

  // 写入平台文件内容（json）
  Future<bool> writePlatformFileJson(
      String projectPath, String filePath, Map content) {
    final json = const JsonEncoder.withIndent('  ').convert(content);
    return writePlatformFile(projectPath, filePath, json);
  }

  // 写入平台文件内容（xml）
  Future<bool> writePlatformFileXml(
    String projectPath,
    String filePath,
    XmlDocumentFragment fragment, {
    bool indentAttribute = true,
    String indent = '    ',
  }) async {
    if (fragment.children.isEmpty) return false;
    return writePlatformFile(
      projectPath,
      filePath,
      fragment.children
          .map((e) => e.toXmlString(
                pretty: true,
                indent: indent,
                indentAttribute: (e) => indentAttribute,
              ))
          .join(''),
    );
  }

  @override
  Future<String?> getLabel(String projectPath) async => null;

  @override
  Future<bool> setLabel(String projectPath, String label) async => true;

  @override
  Future<List<PlatformLogo>?> getLogos(String projectPath) async => null;

  @override
  Future<bool> replaceLogo(String projectPath, String logoPath,
      {ProgressCallback? progressCallback}) async {
    convertImageType(String? suffixes) => {
          '.png': ImageType.png,
          '.jpg': ImageType.jpg,
          '.ico': ImageType.ico,
        }[suffixes];
    final logos = await getLogos(projectPath);
    if (logos == null) return false;
    // 遍历图片表，读取原图片信息并将输入logo替换为目标图片
    int index = 0;
    progressCallback?.call(index, logos.length);
    for (final item in logos) {
      final imageType = convertImageType(extension(item.path));
      if (imageType != null) {
        final width = item.size.width.toInt(),
            height = item.size.height.toInt();
        await ImageTool.resizeFile(logoPath, item.path,
            width: width, height: height, imageType: imageType);
      }
      progressCallback?.call(++index, logos.length);
    }
    return true;
  }

  @override
  Future<String?> getPackage(String projectPath) async => null;

  @override
  Future<bool> setPackage(String projectPath, String package) async => true;

  @override
  Future<List<PlatformPermission>?> getFullPermissions() async {
    try {
      final content = await rootBundle.loadString(
        switch (platform) {
          PlatformType.android => Assets.permission.android,
          PlatformType.ios => Assets.permission.ios,
          _ => '',
        },
      );
      return jsonDecode(content)
          .map<PlatformPermission>((e) => (
                name: '${e['name']}',
                desc: '${e['desc']}',
                value: '${e['value']}',
                input: '',
              ))
          .toList();
    } catch (_) {}
    return null;
  }

  @override
  Future<List<PlatformPermission>?> getPermissions(String projectPath) async =>
      null;

  @override
  Future<bool> setPermissions(
          String projectPath, List<PlatformPermission> permissions) async =>
      true;
}

/*
* 平台工具抽象类方法
* @author wuxubaiyang
* @Time 2023/11/29 20:13
*/
abstract mixin class PlatformToolMixin<T extends Record> {
  // 获取平台信息
  Future<PlatformInfo<T>?> getPlatformInfo(String projectPath);

  // 获取项目名
  Future<String?> getLabel(String projectPath);

  // 设置项目名
  Future<bool> setLabel(String projectPath, String label);

  // 获取logo
  Future<List<PlatformLogo>?> getLogos(String projectPath);

  // 替换logo
  Future<bool> replaceLogo(String projectPath, String logoPath,
      {ProgressCallback? progressCallback});

  // 获取包名
  Future<String?> getPackage(String projectPath);

  // 设置包名
  Future<bool> setPackage(String projectPath, String package);

  // 获取该平台完整权限列表
  Future<List<PlatformPermission>?> getFullPermissions();

  // 获取权限列表
  Future<List<PlatformPermission>?> getPermissions(String projectPath);

  // 设置权限列表
  Future<bool> setPermissions(
      String projectPath, List<PlatformPermission> permissions);
}

// 支持平台枚举
enum PlatformType {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}
