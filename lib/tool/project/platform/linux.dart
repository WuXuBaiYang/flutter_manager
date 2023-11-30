import 'platform.dart';

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

}
