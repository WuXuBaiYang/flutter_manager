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

  // 引擎版本
  String engineReversion = '';

  // dart版本号
  String dartVersion = '';

  // 开发版本
  String devToolsVersion = '';

  // 更新时间
  String updatedAt = '';

  // 排序
  int order = 0;

  Environment();

  // 获取环境信息标题
  @ignore
  String get title => 'Flutter · $version · $channel';

  Environment.from(obj)
      : path = obj['path'] ?? '',
        channel = obj['channel'] ?? '',
        gitUrl = obj['gitUrl'] ?? '',
        version = obj['version'] ?? '',
        dartVersion = obj['dartVersion'] ?? '',
        devToolsVersion = obj['devToolsVersion'] ?? '',
        frameworkReversion = obj['frameworkReversion'] ?? '',
        engineReversion = obj['engineReversion'] ?? '',
        updatedAt = obj['updatedAt'] ?? '',
        order = obj['order'] ?? 0;

  // 环境对比
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Environment &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          channel == other.channel &&
          gitUrl == other.gitUrl &&
          version == other.version &&
          dartVersion == other.dartVersion &&
          devToolsVersion == other.devToolsVersion &&
          frameworkReversion == other.frameworkReversion &&
          engineReversion == other.engineReversion &&
          updatedAt == other.updatedAt &&
          order == other.order;

  // 环境哈希值
  @ignore
  @override
  int get hashCode =>
      path.hashCode ^
      channel.hashCode ^
      gitUrl.hashCode ^
      version.hashCode ^
      dartVersion.hashCode ^
      devToolsVersion.hashCode ^
      frameworkReversion.hashCode ^
      engineReversion.hashCode ^
      updatedAt.hashCode ^
      order.hashCode;
}
