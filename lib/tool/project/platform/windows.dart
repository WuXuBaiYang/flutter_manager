import 'dart:io';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/image.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'platform.dart';

// windows平台参数元组
typedef WindowsPlatformInfoTuple = ();

/*
* windows平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class WindowsPlatformTool extends PlatformTool {
  @override
  PlatformType get platform => PlatformType.windows;

  @override
  String get keyFilePath => 'runner/main.cpp';

  // 资源相对路径
  final String _resPath = 'runner/resources';

  // label字段匹配
  final _labelRegExp = RegExp(r'window.Create\(L"(.*)", origin, size\)');

  // label输入限制
  static final labelValidatorRegExp = RegExp(r'^[a-zA-Z1-9_]+$');

  @override
  Future<PlatformInfoTuple<WindowsPlatformInfoTuple>?> getPlatformInfo(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformPath(projectPath),
      label: await getLabel(projectPath) ?? '',
      logos: await getLogos(projectPath) ?? [],
      permissions: <PlatformPermissionTuple>[],
      info: (),
    );
  }

  @override
  Future<List<PlatformLogoTuple>?> getLogos(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final dir = Directory(getPlatformFilePath(projectPath, _resPath));
    final result = <PlatformLogoTuple>[];
    for (final file in dir.listSync()) {
      final path = file.path;
      final name = File(path).name;
      final size = await ImageTool.getSize(path);
      if (name == null || size == null) continue;
      result.add((name: name, path: path, size: size));
    }
    return result;
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final content = await readPlatformFile(projectPath, keyFilePath);
    return content.regFirstGroup(_labelRegExp.pattern, 1);
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    // 如果输入的label不合法，直接返回false
    if (!labelValidatorRegExp.hasMatch(label)) return false;
    var content = await readPlatformFile(projectPath, keyFilePath);
    final temp = _labelRegExp.pattern.replaceFirst('(.*)', label);
    content = content.replaceFirst(_labelRegExp, temp.replaceAll('\\', ''));
    await writePlatformFile(projectPath, keyFilePath, content);
    return true;
  }
}
