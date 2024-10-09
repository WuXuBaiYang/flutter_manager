import 'environment.dart';
import 'package:jtech_base/jtech_base.dart';
import 'project.dart';

/*
* 数据库入口
* @author wuxubaiyang
* @Time 2024/4/28 9:17
*/
class Database extends BaseDatabase with EnvironmentDatabase, ProjectDatabase {
  static final Database _instance = Database._internal();

  factory Database() => _instance;

  Database._internal();

  @override
  Future<Store> createStore(String directory) async {
    return openStore(directory: directory);
  }
}

// 全局单例入口
final database = Database();
