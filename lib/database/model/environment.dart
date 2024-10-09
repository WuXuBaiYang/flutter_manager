import 'package:jtech_base/jtech_base.dart';

@Entity()
class Environment {
  int id;

  // 环境目录
  String path;

  // flutter版本号
  String version;

  // flutter分支
  String channel;

  // git地址
  String gitUrl;

  // 框架版本
  String frameworkReversion;

  // 引擎版本
  String engineReversion;

  // dart版本号
  String dartVersion;

  // 开发版本
  String devToolsVersion;

  // 更新时间
  String updatedAt;

  // 排序
  int order;

  Environment({
    this.path = '',
    this.version = '',
    this.channel = '',
    this.gitUrl = '',
    this.frameworkReversion = '',
    this.engineReversion = '',
    this.dartVersion = '',
    this.devToolsVersion = '',
    this.updatedAt = '',
    this.order = -1,
    this.id = 0,
  });

  // 获取环境信息标题
  @Transient()
  String get title => 'Flutter · $version · $channel';

  Environment copyWith({
    int? id,
    String? path,
    String? version,
    String? channel,
    String? gitUrl,
    String? frameworkReversion,
    String? engineReversion,
    String? dartVersion,
    String? devToolsVersion,
    String? updatedAt,
    int? order,
  }) {
    return Environment()
      ..id = id ?? this.id
      ..path = path ?? this.path
      ..version = version ?? this.version
      ..channel = channel ?? this.channel
      ..gitUrl = gitUrl ?? this.gitUrl
      ..frameworkReversion = frameworkReversion ?? this.frameworkReversion
      ..engineReversion = engineReversion ?? this.engineReversion
      ..dartVersion = dartVersion ?? this.dartVersion
      ..devToolsVersion = devToolsVersion ?? this.devToolsVersion
      ..updatedAt = updatedAt ?? this.updatedAt
      ..order = order ?? this.order;
  }
}
