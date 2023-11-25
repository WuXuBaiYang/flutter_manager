import 'package:isar/isar.dart';

part 'environment.g.dart';

@collection
class Environment {
  Id id = Isar.autoIncrement;

  // 环境目录
  String path = '';

  // flutter分支
  String channel = '';

  // flutter版本号
  String version = '';

  // dart版本号
  String dartVersion = '';

  // 开发版本
  String devVersion = '';

  // 框架版本
  String frameworkReversion = '';

  // 引擎版本
  String engineReversion = '';

  // 更新时间
  String updatedAt = '';
}
