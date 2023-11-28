import 'dart:io';

import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/project/project.dart';

/*
* 项目提供者
* @author wuxubaiyang
* @Time 2023/11/26 18:56
*/
class ProjectProvider extends BaseProvider {
  // 置顶项目集合
  List<Project>? _pinnedProjects;

  // 获取置顶项目集合
  List<Project> get pinnedProjects => _pinnedProjects ?? [];

  // 项目集合
  List<Project>? _projects;

  // 获取项目集合
  List<Project> get projects => _projects ?? [];

  ProjectProvider() {
    initialize();
  }

  // 获取项目集合
  Future<void> initialize() async {
    _pinnedProjects = await database.getProjectList(true);
    _projects = await database.getProjectList();
    notifyListeners();
  }

  // 添加项目信息
  Future<Project?> update(Project item) async {
    dynamic cacheFile = item.logo;
    if (File(item.logo).existsSync()) {
      cacheFile = await ProjectTool.cacheFile(item.logo);
    }
    final result = await database.updateProject(
      item..logo = cacheFile ?? '',
    );
    await initialize();
    return result;
  }

  // 项目置顶
  Future<void> pinned(Project project, [bool pinned = true]) async {
    await database.updateProject(
      project..pinned = pinned,
    );
    return initialize();
  }

  // 移除项目
  Future<void> remove(Project project) async {
    await database.removeProject(project.id);
    return initialize();
  }
}
