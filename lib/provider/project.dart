import 'dart:io';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/tool.dart';

// 项目信息元组类型
typedef ProjectTuple = ({List<Project> projects, List<Project> pinnedProjects});

/*
* 项目提供者
* @author wuxubaiyang
* @Time 2023/11/26 18:56
*/
class ProjectProvider extends BaseProvider {
  // 最大置顶数量
  static const int maxPinnedCount = 4;

  // 项目元组
  ProjectTuple? _projectTuple;

  // 获取项目集合
  List<Project> get projects => _projectTuple?.projects ?? [];

  // 获取置顶项目集合
  List<Project> get pinnedProjects => _projectTuple?.pinnedProjects ?? [];

  // 判断是否存在项目
  bool get hasProject => projects.isNotEmpty || pinnedProjects.isNotEmpty;

  // 默认项目平台排序表
  List<PlatformType>? _platformSort;

  // 获取默认项目平台排序表
  List<PlatformType> get platformSort =>
      _platformSort ??= ProjectTool.getPlatformSort();

  ProjectProvider() {
    initialize();
  }

  // 获取项目集合
  Future<void> initialize() async {
    final result = await database.getProjectList(orderDesc: true);
    _projectTuple = (projects: <Project>[], pinnedProjects: <Project>[]);
    forEachFun(Project e) => (e.pinned ? pinnedProjects : projects).add(e);
    result.forEach(forEachFun);
    notifyListeners();
  }

  // 更新项目平台排序
  Future<bool> updatePlatformSort(List<PlatformType> platforms) async {
    _platformSort = platforms;
    notifyListeners();
    return ProjectTool.cachePlatformSort(platforms);
  }

  // 添加/编辑项目信息
  Future<Project?> update(Project item) async {
    dynamic cacheFile = item.logo;
    if (File(item.logo).existsSync()) {
      cacheFile = await Tool.cacheFile(item.logo);
    }
    final result = await database.updateProject(
      item..logo = cacheFile ?? '',
    );
    await initialize();
    return result;
  }

  // 项目置顶
  Future<void> togglePinned(Project project) async {
    await database.updateProject(
      project..pinned = !project.pinned,
    );
    return initialize();
  }

  // 移除项目
  Future<void> remove(Project project) async {
    if (!await database.removeProject(project.id)) return;
    return initialize();
  }

  // 对置顶项目重排序
  Future<void> reorderPinned(int oldIndex, int newIndex) async {
    final temp = _swapAndOrder(
      pinnedProjects.reversed.toList(),
      oldIndex,
      newIndex,
    );
    _projectTuple = (
      projects: projects,
      pinnedProjects: temp.reversed.toList(),
    );
    notifyListeners();
    await database.updateProjects(temp);
  }

  // 项目重排序
  Future<void> reorder(int oldIndex, int newIndex) async {
    final temp = _swapAndOrder(
      projects.reversed.toList(),
      oldIndex,
      newIndex,
    );
    _projectTuple = (
      projects: temp.reversed.toList(),
      pinnedProjects: pinnedProjects,
    );
    notifyListeners();
    await database.updateProjects(temp);
  }

  // 交换并重排序
  List<Project> _swapAndOrder(List<Project> list, int oldIndex, int newIndex) {
    newIndex = newIndex > oldIndex ? newIndex + 1 : newIndex;
    final temp = list.swap(oldIndex, newIndex);
    temp.asMap().forEach((i, e) => e.order = i);
    temp.sort((a, b) => a.order.compareTo(b.order));
    return temp;
  }
}
