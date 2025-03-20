import 'dart:io';

import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 项目提供者
* @author wuxubaiyang
* @Time 2023/11/26 18:56
*/
class ProjectProvider extends BaseProvider {
  // 最大置顶数量
  static const int maxPinnedCount = 4;

  // 项目集合
  late List<Project> _projects =
      database.getProjectList(desc: true, pinned: false);

  // 获取项目集合
  List<Project> get projects => _projects;

  // 获取置顶项目集合
  late List<Project> _pinnedProjects =
      database.getProjectList(desc: true, pinned: true);

  // 获取置顶项目集合
  List<Project> get pinnedProjects => _pinnedProjects;

  // 判断是否存在项目
  bool get hasProject => _projects.isNotEmpty || _pinnedProjects.isNotEmpty;

  // 默认项目平台排序表
  late List<PlatformType> _platforms = ProjectTool.getPlatformSort();

  // 获取默认项目平台排序表
  List<PlatformType> get platforms => _platforms;

  ProjectProvider(super.context);

  // 刷新所有项目
  void refresh() {
    _updateProjects();
    _updatePinnedProjects();
  }

  // 调换项目平台排序
  void swapPlatformSort(int oldIndex, int newIndex) {
    _platforms = [..._platforms].swapReorder(oldIndex, newIndex);
    notifyListeners();
  }

  // 更新项目平台排序
  Future<bool> updatePlatformSort(List<PlatformType> platforms) async {
    _platforms = platforms;
    notifyListeners();
    return ProjectTool.cachePlatformSort(platforms);
  }

  // 添加/编辑项目信息
  Future<Project?> update(Project item) async {
    dynamic cacheFile = item.logo;
    if (File(item.logo).existsSync()) {
      cacheFile = await FileTool.cache(item.logo);
    }
    final result = await database.updateProject(
      item..logo = cacheFile ?? '',
    );
    _updateProjects();
    _updatePinnedProjects();
    return result;
  }

  // 项目置顶
  Future<void> togglePinned(Project project) async {
    await database.updateProject(
      project..pinned = !project.pinned,
    );
    _updateProjects();
    _updatePinnedProjects();
  }

  // 移除项目
  bool remove(Project project) {
    final result = database.removeProject(project.id);
    _updateProjects();
    _updatePinnedProjects();
    return result;
  }

  // 对置顶项目重排序
  Future<List<Project>> reorderPinned(int oldIndex, int newIndex) {
    final temp = _swapAndOrder(
      pinnedProjects.reversed.toList(),
      oldIndex,
      newIndex,
    );
    _updatePinnedProjects(projects: temp.reversed.toList());
    return database.updateProjects(temp);
  }

  // 项目重排序
  Future<List<Project>> reorder(int oldIndex, int newIndex) {
    final temp = _swapAndOrder(
      projects.reversed.toList(),
      oldIndex,
      newIndex,
    );
    _updateProjects(projects: temp.reversed.toList());
    return database.updateProjects(temp);
  }

  // 交换并重排序
  List<Project> _swapAndOrder(List<Project> list, int oldIndex, int newIndex) {
    final temp = list.swapReorder(oldIndex, newIndex);
    temp.asMap().forEach((i, e) => e.order = i);
    temp.sort((a, b) => a.order.compareTo(b.order));
    return temp;
  }

  // 更新项目集合
  void _updateProjects({List<Project>? projects, bool desc = true}) {
    projects ??= database.getProjectList(desc: desc, pinned: false);
    _projects = projects;
    notifyListeners();
  }

  // 更新置顶项目集合
  void _updatePinnedProjects({List<Project>? projects, bool desc = true}) {
    projects ??= database.getProjectList(desc: desc, pinned: true);
    _pinnedProjects = projects;
    notifyListeners();
  }
}
