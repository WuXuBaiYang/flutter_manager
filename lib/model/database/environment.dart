import 'package:isar/isar.dart';

part 'environment.g.dart';

@collection
class Environment {
  Id id = Isar.autoIncrement;

  // 环境目录
  @Index(unique: true, replace: true)
  String path = '';

  // flutter版本号
  String version = '';

  // flutter分支
  String channel = '';

  // git地址
  String gitUrl = '';

  // 框架版本
  String frameworkReversion = '';

  // 更新时间
  String updatedAt = '';

  // 引擎版本
  String engineReversion = '';

  // dart版本号
  String dartVersion = '';

  // 开发版本
  String devToolsVersion = '';

  Environment();

  Environment.from(obj)
      : path = obj['path'] ?? '',
        channel = obj['channel'] ?? '',
        gitUrl = obj['gitUrl'] ?? '',
        version = obj['version'] ?? '',
        dartVersion = obj['dartVersion'] ?? '',
        devToolsVersion = obj['devToolsVersion'] ?? '',
        frameworkReversion = obj['frameworkReversion'] ?? '',
        engineReversion = obj['engineReversion'] ?? '',
        updatedAt = obj['updatedAt'] ?? '';
}
