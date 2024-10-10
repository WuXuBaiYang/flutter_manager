import 'package:flutter_manager/objectbox.g.dart';
import 'package:jtech_base/jtech_base.dart';
import 'model/project.dart';

/*
* 项目相关数据库操作
* @author wuxubaiyang
* @Time 2024/4/28 9:19
*/
mixin ProjectDatabase on BaseDatabase {
  // 项目数据盒
  late final projectBox = getBox<Project>();

  // 获取项目数量
  int get projectCount => projectBox.count();

  // 根据环境id获取项目列表
  List<Project> getProjectsByEnvironmentId(int id) {
    return projectBox.query(Project_.envId.equals(id)).build().find();
  }

  // 获取项目列表
  List<Project> getProjectList({bool desc = false, bool pinned = false}) {
    final flags = desc ? Order.descending : 0;
    return projectBox
        .query(Project_.pinned.equals(pinned))
        .order(Project_.order, flags: flags)
        .build()
        .find();
  }

  // 添加/更新项目
  Future<Project> updateProject(Project project) {
    return projectBox.putAndGetAsync(
      project..order = projectCount,
    );
  }

  // 更新项目排序
  Future<List<Project>> updateProjects(List<Project> projects) {
    int index = 0;
    return projectBox.putAndGetManyAsync(projects.map((e) {
      return e..order = index++;
    }).toList());
  }

  // 移除项目
  bool removeProject(int id) {
    return projectBox.remove(id);
  }
}
