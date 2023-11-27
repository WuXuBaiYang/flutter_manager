import 'dart:io';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:path/path.dart';

/*
* 项目管理工具
* @author wuxubaiyang
* @Time 2023/11/27 14:43
*/
class ProjectTool {
  // pubspec文件相对路径
  static const String _pubspecFile = 'pubspec.yaml';

  // 匹配项目名称
  static final RegExp _projectNameReg = RegExp(r'name:.*');

  // 缓存路径
  static const String _cachePath = 'cache';

  // 项目平台目录名
  static const List<String> _projectPlatformDirNames = [
    'android',
    'ios',
    'web',
    'linux',
    'macos',
    'windows',
  ];

  // 判断当前路径是否可用
  static bool isPathAvailable(String path) {
    final file = File(join(path, _pubspecFile));
    return file.existsSync();
  }

  // 读取项目名称
  static Future<String?> getProjectName(String path) async {
    final file = File(join(path, _pubspecFile));
    if (!file.existsSync()) return null;
    final content = await file.readAsString();
    final result = _projectNameReg.stringMatch(content);
    return result?.split(':').lastOrNull?.trim();
  }

  // 缓存目标文件到缓存目录
  static Future<String?> cacheFile(String path) async {
    File file = File(path);
    if (!file.existsSync()) return null;
    final baseDir = await _getCachePath();
    if (baseDir == null) return null;
    final outputPath = join(baseDir, '${Tool.genID()}${file.suffixes}');
    return (await file.copy(outputPath)).path;
  }

  // 获取项目图标
  static Future<String?> getProjectLogo(String path) async {
    /// TODO: 获取项目图标
    // for (var platform in _projectPlatformDirNames) {
    //   final dir = Directory(join(path, platform));
    // }
  }

  // 获取缓存目录
  static Future<String?> _getCachePath() => FileTool.getDirPath(
        join(Common.baseCachePath, _cachePath),
        root: FileDir.applicationDocuments,
      );
}
