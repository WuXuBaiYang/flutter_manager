import 'dart:math';

import 'package:flutter_manager/objectbox.g.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:jtech_base/jtech_base.dart';
import 'model/package.dart';

/*
* 打包相关数据库操作
* @author wuxubaiyang
* @Time 2024/4/28 9:19
*/
mixin PackageDatabase on BaseDatabase {
  // 打包数据
  late final packageBox = getBox<Package>();

  // 更新打包信息
  Future<Package> updatePackage(Package package) {
    return packageBox.putAndGetAsync(package);
  }

  // 移除打包信息
  bool removePackage(int id) {
    return packageBox.remove(id);
  }

  // 批量移除打包信息
  int removePackages(List<int> ids) {
    return packageBox.removeMany(ids);
  }

  // 分页获取打包记录列表
  Future<List<Package>> getPackages({
    int pageIndex = 1,
    int pageSize = 15,
    PackageStatus? status,
    PlatformType? platform,
  }) async {
    pageSize = max(pageSize, 1);
    pageIndex = max(pageIndex, 1);
    final query =
        packageBox
            .query(
              Package_.statusDB
                  .oneOf([if (status != null) status.index])
                  .and(
                    Package_.platformTypeDB.oneOf([
                      if (platform != null) platform.index,
                    ]),
                  ),
            )
            .order(Package_.createAt, flags: Order.descending)
            .build()
          ..offset = (pageIndex - 1) * pageSize
          ..limit = pageSize;
    return query.find();
  }
}
