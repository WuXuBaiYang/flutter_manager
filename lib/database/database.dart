import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/database/project.dart';

import 'base/base.dart';
import 'environment.dart';

/*
* 数据库入口
* @author wuxubaiyang
* @Time 2024/4/28 9:17
*/
class Database extends BaseDatabase with EnvironmentDatabase, ProjectDatabase {
  static final Database _instance = Database._internal();

  factory Database() => _instance;

  Database._internal()
      : super([
          EnvironmentSchema,
          ProjectSchema,
        ], name: Common.databaseName);
}

// 全局单例入口
final database = Database();
