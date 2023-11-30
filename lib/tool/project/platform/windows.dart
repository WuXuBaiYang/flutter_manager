import 'dart:io';
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
  String get keyFilePath => 'runner/flutter_window.cpp';

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
}
