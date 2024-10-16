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
  late final envBox = getBox<Environment>();

  // 根据id获取环境信息
  Environment? getEnvById(int? id) {
    if (id == null) return null;
    return envBox.get(id);
  }

  // 获取环境数量
  int get envCount {
    return envBox.count();
  }

  // 获取全部环境列表
  List<Environment> getEnvList({bool desc = false}) {
    final flags = desc ? Order.descending : 0;
    return envBox
        .query()
        .order(Environment_.order, flags: flags)
        .build()
        .find();
  }

  // 添加/更新环境
  Future<Environment> updateEnv(Environment env) {
    return envBox.putAndGetAsync(
      env..order = envCount,
    );
  }

  // 更新环境集合
  Future<List<Environment>> updateEnvs(List<Environment> envs) {
    int index = 0;
    return envBox.putAndGetManyAsync(envs.map((e) {
      return e..order = index++;
    }).toList());
  }

  // 移除环境
  bool removeEnv(int id) => envBox.remove(id);
}
