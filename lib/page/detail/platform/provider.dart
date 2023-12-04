import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:flutter_manager/tool/project/project.dart';

/*
* 平台组件数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 9:45
*/
class PlatformProvider extends BaseProvider {
  // 平台信息表
  final _platformInfoMap = <PlatformType, Record?>{};

  // 获取android平台信息
  AndroidPlatformInfoTuple? get androidInfo =>
      _platformInfoMap[PlatformType.android] as AndroidPlatformInfoTuple?;

  // 获取ios平台信息
  IosPlatformInfoTuple? get iosInfo =>
      _platformInfoMap[PlatformType.ios] as IosPlatformInfoTuple?;

  // 获取web平台信息
  WebPlatformInfoTuple? get webInfo =>
      _platformInfoMap[PlatformType.web] as WebPlatformInfoTuple?;

  // 获取windows平台信息
  WindowsPlatformInfoTuple? get windowsInfo =>
      _platformInfoMap[PlatformType.windows] as WindowsPlatformInfoTuple?;

  // 获取macos平台信息
  MacosPlatformInfoTuple? get macosInfo =>
      _platformInfoMap[PlatformType.macos] as MacosPlatformInfoTuple?;

  // 获取linux平台信息
  LinuxPlatformInfoTuple? get linuxInfo =>
      _platformInfoMap[PlatformType.linux] as LinuxPlatformInfoTuple?;

  PlatformProvider(Project project) {
    initialize(project.path);
  }

  // 初始化平台信息
  Future<void> initialize(String projectPath) async {
    await Future.wait(PlatformType.values.map(
      (e) => _updatePlatformInfo(e, projectPath, false),
    ));
    notifyListeners();
  }

  // 更新label
  Future<bool> updateLabel(
      PlatformType platform, String projectPath, String label) async {
    final result = await ProjectTool.setLabel(platform, projectPath, label);
    if (result) _updatePlatformInfo(platform, projectPath);
    return result;
  }

  // 更新图标
  Future<bool> updateLogo(
      PlatformType platform, String projectPath, String logoPath) async {
    final result =
        await ProjectTool.replaceLogo(platform, projectPath, logoPath);
    if (result) _updatePlatformInfo(platform, projectPath);
    return result;
  }

  // 更新平台信息
  Future<void> _updatePlatformInfo(PlatformType platform, String projectPath,
      [bool notify = true]) async {
    _platformInfoMap[platform] =
        await ProjectTool.getPlatformInfo(platform, projectPath);
    if (notify) notifyListeners();
  }
}
