import 'platform.dart';

/*
* macos平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class MacosPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.macos;

  @override
  String get keyFilePath => '';

  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return {};
  }
}
