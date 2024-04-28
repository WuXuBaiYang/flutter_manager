import 'package:isar/isar.dart';

import 'base/base.dart';
import 'model/environment.dart';
import 'model/project.dart';

/*
* 环境相关数据库操作
* @author wuxubaiyang
* @Time 2024/4/28 9:19
*/
mixin EnvironmentDatabase on BaseDatabase {
  // 根据环境id获取项目列表
  Future<List<Project>> getProjectsByEnvironmentId(Id id) {
    return isar.projects.where().filter().envIdEqualTo(id).findAll();
  }

  // 根据id获取环境信息
  Future<Environment?> getEnvironmentById(Id id) {
    return isar.environments.where().idEqualTo(id).findFirst();
  }

  // 获取环境数量
  Future<int> get environmentCount async => (await getEnvironmentList()).length;

  // 获取全部环境列表
  Future<List<Environment>> getEnvironmentList({bool orderDesc = false}) {
    var queryBuilder = isar.environments.where();
    if (orderDesc) return queryBuilder.sortByOrderDesc().findAll();
    return queryBuilder.sortByOrder().findAll();
  }

  // 添加/更新环境
  Future<Environment> updateEnvironment(Environment item) async {
    final count = await environmentCount;
    return writeTxn<Environment>(() {
      return isar.environments.put(item..order = count).then(
            (id) => item..id = id,
          );
    });
  }

  // 更新环境集合
  Future<List<Environment>> updateEnvironments(List<Environment> items) =>
      writeTxn<List<Environment>>(() {
        return isar.environments.putAll(items).then((_) => items);
      });

  // 移除环境
  Future<bool> removeEnvironment(Id id) => writeTxn<bool>(() {
        return isar.environments.delete(id);
      });
}
