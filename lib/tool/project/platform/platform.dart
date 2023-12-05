import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:xml/xml.dart';

// 平台图标信息元组
typedef PlatformLogoTuple = ({String name, String path, Size size});

/*
* 平台工具抽象类
* @author wuxubaiyang
* @Time 2023/11/29 18:37
*/
abstract class PlatformTool with PlatformToolMixin {
  // 平台文件夹路径
  PlatformType get platform;

  // 关键文件相对路径
  String get keyFilePath;

  // 获取平台文件夹路径
  String get platformPath => platform.name;

  // 判断当前路径是否可用
  bool isPathAvailable(String projectPath) =>
      File(join(getPlatformType(projectPath), keyFilePath)).existsSync();

  // 获取平台路径
  String getPlatformType(String projectPath) => join(projectPath, platformPath);

  // 获取平台文件路径
  String getPlatformFilePath(String projectPath, String filePath) =>
      join(getPlatformType(projectPath), filePath);

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
  Future<File> writePlatformFile(
      String projectPath, String filePath, String content) async {
    final file = File(getPlatformFilePath(projectPath, filePath));
    await autoBackup(projectPath, filePath);
    return file.writeAsString(content);
  }

  // 写入平台文件内容（json）
  Future<File> writePlatformFileJson(
      String projectPath, String filePath, Map content) {
    final json = const JsonEncoder.withIndent('  ').convert(content);
    return writePlatformFile(projectPath, filePath, json);
  }

  // 写入平台文件内容（xml）
  Future<File?> writePlatformFileXml(
    String projectPath,
    String filePath,
    XmlDocumentFragment fragment, {
    bool indentAttribute = true,
    String indent = '    ',
  }) async {
    if (fragment.children.isEmpty) return null;
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

  // 获取图片尺寸
  Future<Size?> getImageSize(String logoPath) async {
    final image = await img.decodeImageFile(logoPath);
    final width = image?.width.toDouble();
    final height = image?.height.toDouble();
    if (width == null || height == null) return null;
    return Size(width, height);
  }

  @override
  Future<List<PlatformLogoTuple>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return <PlatformLogoTuple>[];
  }

  @override
  Future<bool> replaceLogo(String projectPath, String logoPath,
      {ProgressCallback? progressCallback}) async {
    final logoInfoList = await getLogoInfo(projectPath);
    if (logoInfoList == null) return false;
    // 遍历图片表，读取原图片信息并将输入logo替换为目标图片
    int index = 0;
    progressCallback?.call(index, logoInfoList.length);
    for (final item in logoInfoList) {
      final suffixes = File(item.path).suffixes;
      if (suffixes?.isEmpty ?? true) continue;
      var cmd = img.Command()
        ..decodeImageFile(logoPath)
        ..copyResize(
          width: item.size.width.toInt(),
          height: item.size.height.toInt(),
        );
      if (suffixes == '.png') cmd = cmd..encodePng();
      if (suffixes == '.jpg') cmd = cmd..encodeJpg();
      if (suffixes == '.ico') cmd = cmd..encodeIco();
      await (cmd..writeToFile(item.path)).executeThread();
      progressCallback?.call(++index, logoInfoList.length);
    }
    return true;
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return '';
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async => true;
}

/*
* 平台工具抽象类方法
* @author wuxubaiyang
* @Time 2023/11/29 20:13
*/
abstract mixin class PlatformToolMixin {
  // 获取平台信息
  Future<Record?> getPlatformInfo(String projectPath);

  // 获取logo
  Future<List<PlatformLogoTuple>?> getLogoInfo(String projectPath);

  // 替换logo
  Future<bool> replaceLogo(String projectPath, String logoPath,
      {ProgressCallback? progressCallback});

  // 获取项目名
  Future<String?> getLabel(String projectPath);

  // 设置项目名
  Future<bool> setLabel(String projectPath, String label);
}

/*
* 支持平台枚举
* @author wuxubaiyang
* @Time 2023/11/29 18:58
*/
enum PlatformType {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}
