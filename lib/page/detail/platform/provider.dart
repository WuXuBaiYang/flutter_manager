import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/dialog/project_logo.dart';
import 'package:provider/provider.dart';

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

  // 获取全平台（存在）标签对照表(按照设置排序)
  Map<PlatformType, String> getLabelMap(BuildContext context) {
    final result = {
      if (androidInfo != null) PlatformType.android: androidInfo!.label,
      if (iosInfo != null) PlatformType.ios: iosInfo!.label,
      if (webInfo != null) PlatformType.web: webInfo!.label,
      if (windowsInfo != null) PlatformType.windows: windowsInfo!.label,
      if (macosInfo != null) PlatformType.macos: macosInfo!.label,
      if (linuxInfo != null) PlatformType.linux: linuxInfo!.label,
    };
    for (var e in context.read<ProjectProvider>().platformSort) {
      final value = result.remove(e);
      if (value != null) result[e] = value;
    }
    return result;
  }

  // 获取全平台（存在）图标对照表
  Map<PlatformType, List<PlatformLogoTuple>> getLogoMap(BuildContext context) {
    final result = {
      if (androidInfo?.logo != null) PlatformType.android: androidInfo!.logo!,
      if (iosInfo?.logo != null) PlatformType.ios: iosInfo!.logo,
      if (webInfo?.logo != null) PlatformType.web: webInfo!.logo,
      if (windowsInfo?.logo != null) PlatformType.windows: windowsInfo!.logo,
      if (macosInfo?.logo != null) PlatformType.macos: macosInfo!.logo,
      if (linuxInfo?.logo != null) PlatformType.linux: linuxInfo!.logo,
    };
    for (var e in context.read<ProjectProvider>().platformSort) {
      final value = result.remove(e);
      if (value != null) result[e] = value;
    }
    return result;
  }

  // 批量更新label
  Future<void> updateLabels(
      String projectPath, Map<PlatformType, String> platformLabels) async {
    await Future.wait(platformLabels.entries.map(
      (e) => ProjectTool.setLabel(e.key, projectPath, e.value),
    ));
    return initialize(projectPath);
  }

  // 批量更新图标
  Future<void> updateLogos(
      String projectPath, ProjectLogoDialogFormTuple result,
      {ProgressCallback? progressCallback, int total = -1}) async {
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
