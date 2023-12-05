import 'dart:async';

import 'package:dio/dio.dart';
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
import 'package:flutter_manager/widget/dialog/project_logo.dart';

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

  // 获取全平台（存在）标签对照表
  Map<PlatformType, String> get labelMap {
    final result = {
      PlatformType.android: androidInfo?.label,
      PlatformType.ios: iosInfo?.label,
      PlatformType.web: webInfo?.label,
      PlatformType.windows: windowsInfo?.label,
      PlatformType.macos: macosInfo?.label,
      PlatformType.linux: linuxInfo?.label,
    };
    result.removeWhere((_, v) => v == null);
    return result.map((k, v) => MapEntry(k, v!));
  }

  // 获取全平台（存在）图标对照表
  Map<PlatformType, List<PlatformLogoTuple>> get logoMap {
    final result = {
      PlatformType.android: androidInfo?.logo,
      PlatformType.ios: iosInfo?.logo,
      PlatformType.web: webInfo?.logo,
      PlatformType.windows: windowsInfo?.logo,
      PlatformType.macos: macosInfo?.logo,
      PlatformType.linux: linuxInfo?.logo,
    };
    result.removeWhere((_, v) => v?.isEmpty ?? true);
    return result.map((k, v) => MapEntry(k, v!));
  }

  // 批量更新label
  Future<void> updateLabels(
      String projectPath, List<PlatformType> platforms, String label) async {
    await Future.wait(labelMap.entries.map(
      (e) => ProjectTool.setLabel(e.key, projectPath, e.value),
    ));
    return initialize(projectPath);
  }

  // 批量更新图标
  Future<void> updateLogos(
    String projectPath,
    ProjectLogoDialogFormTuple result, {
    ProgressCallback? progressCallback,
    int total = -1,
  }) async {
    int count = 0;
    await Future.wait(result.platforms.map(
      (e) => ProjectTool.replaceLogo(e, projectPath, result.logo,
          progressCallback: (_, __) => progressCallback?.call(count++, total)),
    ));
    return initialize(projectPath);
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
