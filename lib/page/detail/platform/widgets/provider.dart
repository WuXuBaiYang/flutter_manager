import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/project.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/dialog/project_logo.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

/*
* 平台组件数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 9:45
*/
class PlatformProvider extends BaseProvider with WindowListener {
  // 项目信息
  final Project? project;

  // 平台信息表
  final _platformInfoMap = <PlatformType, PlatformInfoTuple?>{};

  // 当前支持的平台列表（排序后）
  List<PlatformType> _platformList = [];

  // 获取当前支持的平台列表（排序后）
  List<PlatformType> get platformList => _platformList;

  // 缓存机制，缓存临时输入内容(当触发initialize的时候清空)
  final _cacheMap = <String, dynamic>{};

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

  PlatformProvider(super.context, this.project) {
    if (project != null) initialize();
    windowManager.addListener(this);
  }

  @override
  void onWindowFocus() {
    // 当窗口重新获取焦点的时候刷新数据
    if (project != null) initialize();
  }

  // 初始化平台信息
  Future<void> initialize() async {
    if (project == null) return;
    _platformList = ProjectTool.getPlatforms(project!.path);
    final platformSort = context.read<ProjectProvider>().platformSort;
    for (var e in platformSort) {
      if (!_platformList.contains(e)) continue;
      _platformList.remove(e);
      _platformList.add(e);
    }
    await Future.wait(PlatformType.values.map(
      (e) => updatePlatformInfo(e, false),
    ));
    notifyListeners();
  }

  // 写入缓存
  T cache<T>(String cacheKey, T item) => _cacheMap[cacheKey] = item;

  // 读取缓存
  T? restoreCache<T>(String cacheKey) => _cacheMap[cacheKey] as T?;

  // 清除全部缓存（不触发刷新）
  void clearCache() => _cacheMap.clear();

  // 根据平台清除缓存（不触发刷新）
  void clearCacheByPlatform(PlatformType platform) =>
      _cacheMap.removeWhere((k, _) => k.contains('$platform'));

  // 获取平台信息元组
  PlatformInfoTuple<T>? getPlatformTuple<T extends Record>(
          PlatformType platform) =>
      _platformInfoMap[platform] as PlatformInfoTuple<T>?;

  // 创建平台
  Future<void> createPlatform(PlatformType platform) async {
    if (project == null) return;
    try {
      final result = await ProjectTool.createPlatform(project!, platform);
      if (result) return updatePlatformInfo(platform);
    } catch (e) {
      showError(e.toString(), title: '创建失败');
    }
  }

  // 移除平台
  Future<void> removePlatform(PlatformType platform) async {
    if (project == null) return;
    try {
      final result = await ProjectTool.removePlatform(project!, platform);
      if (result) updatePlatformInfo(platform);
    } catch (e) {
      showError(e.toString(), title: '移除失败');
    }
  }

  // 批量更新label
  Future<void> updateLabels(Map<PlatformType, String>? labelData) async {
    if (project == null || labelData == null) return;
    try {
      await Future.wait(labelData.entries
          .map((e) => ProjectTool.setLabel(project!.path, e.key, e.value)));
      return initialize();
    } catch (e) {
      showError(e.toString(), title: '标签修改失败');
    }
  }

  // 批量更新图标
  Future<void> updateLogos(ProjectLogoDialogFormTuple? logoData,
      {StreamController<double>? controller}) async {
    if (project == null || logoData == null) return;
    try {
      double progress = 0;
      final ratio = 1 / logoData.platforms.length;
      for (var e in logoData.platforms) {
        await ProjectTool.replaceLogo(project!.path, e, logoData.logo,
            progressCallback: (c, t) {
          final part = ratio * (c / t);
          controller?.add(progress + part);
        });
        progress += ratio;
      }
      return initialize();
    } catch (e) {
      showError(e.toString(), title: '图标修改失败');
    }
  }

  // 更新label
  Future<void> updateLabel(PlatformType platform, String label) async {
    if (project == null) return;
    try {
      final result = await ProjectTool.setLabel(project!.path, platform, label);
      if (result) updatePlatformInfo(platform);
    } catch (e) {
      showError(e.toString(), title: '标签修改失败');
    }
  }

  // 更新图标
  Future<void> updateLogo(PlatformType platform, String logoPath,
      {ProgressCallback? progressCallback}) async {
    if (project == null) return;
    try {
      final result = await ProjectTool.replaceLogo(
          project!.path, platform, logoPath,
          progressCallback: progressCallback);
      if (result) updatePlatformInfo(platform);
    } catch (e) {
      showError(e.toString(), title: '图标修改失败');
    }
  }

  // 更新权限
  Future<void> updatePermission(
      PlatformType platform, List<PlatformPermissionTuple>? permissions) async {
    if (project == null || permissions == null) return;
    try {
      final result = await ProjectTool.setPermissions(
          project!.path, platform, permissions);
      if (result) updatePlatformInfo(platform);
    } catch (e) {
      showError(e.toString(), title: '权限修改失败');
    }
  }

  // 更新平台信息
  Future<void> updatePlatformInfo(PlatformType platform,
      [bool notify = true]) async {
    if (project == null) return;
    _platformInfoMap[platform] =
        await ProjectTool.getPlatformInfo(project!.path, platform);
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
