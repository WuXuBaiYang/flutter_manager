import 'dart:async';
import 'package:dio/dio.dart';
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

  PlatformProvider(super.context, Project project) {
    initialize(project.path);
  }

  // 获取平台信息元组
  PlatformInfoTuple<T>? getPlatformTuple<T extends Record>(
          PlatformType platform) =>
      _platformInfoMap[platform] as PlatformInfoTuple<T>?;

  // 初始化平台信息
  Future<void> initialize(String projectPath) async {
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
  Future<void> createPlatform(Project? project, PlatformType platform) async {
    if (project == null) return;
    try {
      final result = await ProjectTool.createPlatform(project, platform);
      if (result) return initialize(project.path);
    } catch (e) {
      showMessage('创建失败：${e.toString()}');
    }
  }

  // 移除平台
  Future<void> removePlatform(Project? project, PlatformType platform) async {
    if (project == null) return;
    return ProjectTool.removePlatform(project, platform)
        .then((result) async => initialize(project.path));
  }

  // 获取全平台（存在）标签对照表(按照设置排序)
  Map<PlatformType, String> get labelMap {
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
  Map<PlatformType, List<PlatformLogoTuple>> get logoMap {
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
  Future<void> updateLabels(
      String projectPath, Map<PlatformType, String>? labelData) async {
    if (labelData == null) return;
    try {
      await Future.wait(labelData.entries
          .map((e) => ProjectTool.setLabel(e.key, projectPath, e.value)));
      return initialize(projectPath);
    } catch (e) {
      showMessage('标签修改失败：${e.toString()}');
    }
  }

  // 批量更新图标
  Future<void> updateLogos(
      String projectPath, ProjectLogoDialogFormTuple? logoData,
      {StreamController<double>? controller}) async {
    if (logoData == null) return;
    try {
      double progress = 0;
      final ratio = 1 / logoData.platforms.length;
      for (var e in logoData.platforms) {
        await ProjectTool.replaceLogo(e, projectPath, logoData.logo,
            progressCallback: (c, t) {
          final part = ratio * (c / t);
          controller?.add(progress + part);
        });
        progress += ratio;
      }
      return initialize(projectPath);
    } catch (e) {
      showMessage('图标修改失败：${e.toString()}');
    }
  }

  // 更新label
  Future<void> updateLabel(
      PlatformType platform, String projectPath, String label) async {
    try {
      final result = await ProjectTool.setLabel(platform, projectPath, label);
      if (result) _updatePlatformInfo(platform, projectPath);
    } catch (e) {
      showMessage('标签修改失败：${e.toString()}');
    }
  }

  // 更新图标
  Future<void> updateLogo(
      PlatformType platform, String projectPath, String logoPath,
      {ProgressCallback? progressCallback}) async {
    try {
      final result = await ProjectTool.replaceLogo(
          platform, projectPath, logoPath,
          progressCallback: progressCallback);
      if (result) _updatePlatformInfo(platform, projectPath);
    } catch (e) {
      showMessage('图标修改失败：${e.toString()}');
    }
  }

  // 更新平台信息
  Future<void> _updatePlatformInfo(PlatformType platform, String projectPath,
      [bool notify = true]) async {
    _platformInfoMap[platform] =
        await ProjectTool.getPlatformInfo(platform, projectPath);
    if (notify) notifyListeners();
  }
}
