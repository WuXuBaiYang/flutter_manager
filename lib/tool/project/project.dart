import 'dart:io';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:path/path.dart';

/*
* 项目管理工具
* @author wuxubaiyang
* @Time 2023/11/27 14:43
*/
class ProjectTool {
  // 关键文件相对路径
  static const String _keyFilePath = 'pubspec.yaml';

  // 匹配项目名称
  static final RegExp _projectNameReg = RegExp(r'name:.*');

  // 缓存路径
  static const String _cachePath = 'cache';

  // 获取项目信息
  static Future<Project?> getProjectInfo(String path) async {
    if (!isPathAvailable(path)) return null;
    return Project()
      ..path = path
      ..label = await ProjectTool.getProjectName(path) ?? ''
      ..logo = await ProjectTool.getProjectLogo(path) ?? '';
  }

  // 判断当前路径是否可用
  static bool isPathAvailable(String projectPath) {
    final file = File(join(projectPath, _keyFilePath));
    return file.existsSync();
  }

  // 读取项目名称
  static Future<String?> getProjectName(String projectPath) async {
    final file = File(join(projectPath, _keyFilePath));
    if (!file.existsSync()) return null;
    final content = await file.readAsString();
    final result = _projectNameReg.stringMatch(content);
    return result?.split(':').lastOrNull?.trim();
  }

  // 缓存目标文件到缓存目录
  static Future<String?> cacheFile(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) return null;
    final baseDir = await _getCachePath();
    if (baseDir == null) return null;
    final outputPath = join(baseDir, '${Tool.genID()}${file.suffixes}');
    return (await file.copy(outputPath)).path;
  }

  // 获取项目图标
  static Future<String?> getProjectLogo(String projectPath) async {
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
