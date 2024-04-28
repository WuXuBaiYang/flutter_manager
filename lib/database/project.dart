import 'package:isar/isar.dart';

import 'base/base.dart';
import 'model/project.dart';

/*
* 项目相关数据库操作
* @author wuxubaiyang
* @Time 2024/4/28 9:19
*/
mixin ProjectDatabase on BaseDatabase {
  // 获取项目数量
  Future<int> get projectCount async => (await getProjectList()).length;

  // 获取项目列表
  Future<List<Project>> getProjectList({bool orderDesc = false}) {
    var queryBuilder = isar.projects.where();
    if (orderDesc) return queryBuilder.sortByOrderDesc().findAll();
    return queryBuilder.sortByOrder().findAll();
  }

  // 添加/更新项目
  Future<Project?> updateProject(Project item) async {
    final count = await projectCount;
    return writeTxn<Project?>(() {
      return isar.projects.put(item..order = count).then(
            (id) => item..id = id,
          );
    });
  }

  // 更新项目排序
  Future<List<Project>> updateProjects(List<Project> items) =>
      writeTxn<List<Project>>(() {
        return isar.projects.putAll(items).then((_) => items);
      });

  // 移除项目
  Future<bool> removeProject(Id id) => writeTxn<bool>(() {
        return isar.projects.delete(id);
      });
}
