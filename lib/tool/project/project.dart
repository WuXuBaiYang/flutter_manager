import 'dart:io';
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
}
