import 'package:flutter_manager/objectbox.g.dart';
import 'package:jtech_base/jtech_base.dart';
import 'model/environment.dart';

/*
* 环境相关数据库操作
* @author wuxubaiyang
* @Time 2024/4/28 9:19
*/
mixin EnvironmentDatabase on BaseDatabase {
  // 环境数据盒子
  late final environmentBox = getBox<Environment>();

  // 根据id获取环境信息
  Environment? getEnvironmentById(int? id) {
    if (id == null) return null;
    return environmentBox.get(id);
  }

  // 获取环境数量
  int get environmentCount {
    return environmentBox.count();
  }

  // 获取全部环境列表
  List<Environment> getEnvironmentList({bool desc = false}) {
    final flags = desc ? Order.descending : 0;
    return environmentBox
        .query()
        .order(Environment_.order, flags: flags)
        .build()
        .find();
  }

  // 添加/更新环境
  Future<Environment> updateEnvironment(Environment environment) {
    return environmentBox.putAndGetAsync(
      environment..order = environmentCount,
    );
  }

  // 更新环境集合
  Future<List<Environment>> updateEnvironments(List<Environment> environments) {
    int index = 0;
    return environmentBox.putAndGetManyAsync(environments.map((e) {
      return e..order = index++;
    }).toList());
  }

  // 移除环境
  bool removeEnvironment(int id) {
    return environmentBox.remove(id);
  }
}
