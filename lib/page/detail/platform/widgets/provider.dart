import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
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
  final _platformInfoMap = <PlatformType, PlatformInfoTuple?>{};

  // 当前支持的平台列表（排序后）
  List<PlatformType> _platformList = [];

  // 获取当前支持的平台列表（排序后）
  List<PlatformType> get platformList => _platformList;

  PlatformProvider(BuildContext context, Project project) {
    initialize(context, project.path);
  }

  // 获取平台信息元组
  PlatformInfoTuple<T>? getPlatformTuple<T extends Record>(
          PlatformType platform) =>
      _platformInfoMap[platform] as PlatformInfoTuple<T>?;

  // 初始化平台信息
  Future<void> initialize(BuildContext context, String projectPath) async {
    _platformList = ProjectTool.getPlatforms(projectPath);
    final platformSort = context.read<ProjectProvider>().platformSort;
    for (var e in platformSort) {
      if (!_platformList.contains(e)) continue;
      _platformList.remove(e);
      _platformList.add(e);
    }
    await Future.wait(PlatformType.values.map(
      (e) => _updatePlatformInfo(e, projectPath, false),
    ));
    notifyListeners();
  }

  // 创建平台
  Future<void> createPlatform(
      BuildContext context, Project project, PlatformType platform) {
    return ProjectTool.createPlatform(project, platform)
        .then((result) async => initialize(context, project.path));
  }

  // 移除平台
  Future<void> removePlatform(
      BuildContext context, Project project, PlatformType platform) {
    return ProjectTool.removePlatform(project, platform)
        .then((result) async => initialize(context, project.path));
  }

  // 获取全平台（存在）标签对照表(按照设置排序)
  Map<PlatformType, String> getLabelMap(BuildContext context) {
    var result = {..._platformInfoMap}..removeWhere((_, v) => v?.label == null);
    for (var e in context.read<ProjectProvider>().platformSort) {
      final value = result.remove(e);
      if (value != null) result[e] = value;
    }
    return result.map<PlatformType, String>(
      (k, v) => MapEntry(k, v!.label),
    );
  }

  // 获取全平台（存在）图标对照表
  Map<PlatformType, List<PlatformLogoTuple>> getLogoMap(BuildContext context) {
    var result = {..._platformInfoMap}
      ..removeWhere((_, v) => v?.logos.isEmpty ?? true);
    for (var e in context.read<ProjectProvider>().platformSort) {
      final value = result.remove(e);
      if (value != null) result[e] = value;
    }
    return result.map<PlatformType, List<PlatformLogoTuple>>(
      (k, v) => MapEntry(k, v!.logos),
    );
  }

  // 批量更新label
  Future<void> updateLabels(BuildContext context, String projectPath,
      Map<PlatformType, String> platformLabels) {
    return Future.wait(platformLabels.entries.map(
      (e) => ProjectTool.setLabel(e.key, projectPath, e.value),
    )).then((_) async => initialize(context, projectPath));
  }

  // 批量更新图标
  Future<void> updateLogos(BuildContext context, String projectPath,
      ProjectLogoDialogFormTuple result,
      {ProgressCallback? progressCallback, int total = -1}) {
    int count = 0;
    return Future.forEach(result.platforms, (e) {
      return ProjectTool.replaceLogo(e, projectPath, result.logo,
          progressCallback: (c, t) {
        progressCallback?.call(count + c, total);
        if (c >= t) count += c;
      });
    }).then((_) async => initialize(context, projectPath));
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
      PlatformType platform, String projectPath, String logoPath,
      {ProgressCallback? progressCallback}) async {
    final result = await ProjectTool.replaceLogo(
        platform, projectPath, logoPath,
        progressCallback: progressCallback);
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
