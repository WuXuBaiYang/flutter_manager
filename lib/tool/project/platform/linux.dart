import 'package:flutter_manager/model/platform.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'platform.dart';

// linux平台参数元组
typedef LinuxPlatformTuple = ({
  String path,
  String label,
  List<PlatformLogoTuple> logo,
});

/*
* linux平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:58
*/
class LinuxPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.linux;

  @override
  String get keyFilePath => 'main.cc';

  // my_application.cc相对路径
  final String _myApplicationPath = 'my_application.cc';

  // label标签替换正则集合
  final _labelRegExpList = [
    RegExp(r'gtk_header_bar_set_title\(header_bar, "(.*)"\);'),
    RegExp(r'gtk_window_set_title\(window, "(.*)"\);'),
  ];

  @override
  Future<PlatformInfo?> getPlatformInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return LinuxPlatformInfo(
      path: getPlatformPath(projectPath),
      label: await getLabel(projectPath) ?? '',
      logo: await getLogoInfo(projectPath) ?? [],
    );
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final content = await readPlatformFile(projectPath, _myApplicationPath);
    for (var e in _labelRegExpList) {
      final value = content.regFirstGroup(e.pattern, 1);
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    var content = await readPlatformFile(projectPath, _myApplicationPath);
    for (var reg in _labelRegExpList) {
      final temp = reg.pattern.replaceFirst('(.*)', label);
      content = content.replaceFirst(reg, temp.replaceAll('\\', ''));
    }
    await writePlatformFile(projectPath, _myApplicationPath, content);
    return true;
  }
}
