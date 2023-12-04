import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';

/*
* 平台组件数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 9:45
*/
class PlatformProvider extends BaseProvider {
  // android平台信息
  AndroidPlatformInfoTuple? _androidPlatformInfo;

  // 获取android平台信息
  AndroidPlatformInfoTuple? get androidPlatformInfo => _androidPlatformInfo;

  // ios平台信息
  IosPlatformInfoTuple? _iosPlatformInfo;

  // 获取ios平台信息
  IosPlatformInfoTuple? get iosPlatformInfo => _iosPlatformInfo;

  // web平台信息
  WebPlatformInfoTuple? _webPlatformInfo;

  // 获取web平台信息
  WebPlatformInfoTuple? get webPlatformInfo => _webPlatformInfo;

  // windows平台信息
  WindowsPlatformInfoTuple? _windowsPlatformInfo;

  // 获取windows平台信息
  WindowsPlatformInfoTuple? get windowsPlatformInfo => _windowsPlatformInfo;

  // macos平台信息
  MacosPlatformInfoTuple? _macosPlatformInfo;

  // 获取macos平台信息
  MacosPlatformInfoTuple? get macosPlatformInfo => _macosPlatformInfo;

  // linux平台信息
  LinuxPlatformInfoTuple? _linuxPlatformInfo;

  // 获取linux平台信息
  LinuxPlatformInfoTuple? get linuxPlatformInfo => _linuxPlatformInfo;

  PlatformProvider(Project project) {
    initialize(project.path);
  }

  // 初始化平台信息
  Future<void> initialize(String projectPath) async {}
}
