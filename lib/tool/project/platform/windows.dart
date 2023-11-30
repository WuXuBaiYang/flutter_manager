import 'dart:io';
import 'package:flutter_manager/tool/tool.dart';
import 'package:path/path.dart';
import 'platform.dart';

/*
* windows平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class WindowsPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.windows;

  @override
  String get keyFilePath => 'runner/main.cpp';

  // 资源相对路径
  final String _resPath = 'runner/resources';

  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final resPath = getPlatformFilePath(projectPath, _resPath);
    final files = Directory(resPath).listSync();
    return files.asMap().map<String, dynamic>((_, item) {
      final path = item.path;
      final key = basename(path).split('.').first;
      return MapEntry(key, path);
    });
  }

  // label字段匹配
  final _labelRegExp = r'window.Create\(L"(.*)", origin, size\)';

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final content = await readPlatformFile(projectPath, keyFilePath);
    return content.regFirstGroup(_labelRegExp, 1);
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    // 如果输入的label不合法，直接返回false
    if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(label)) return false;
    var content = await readPlatformFile(projectPath, keyFilePath);
    content = content.replaceAll(
        RegExp(_labelRegExp), 'window.Create(L"$label", origin, size)');
    await writePlatformFile(projectPath, keyFilePath, content);
    return true;
  }
}
