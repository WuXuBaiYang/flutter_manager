import 'package:jtech_base/jtech_base.dart';

@Entity()
class Environment {
  int id = 0;

  // 环境目录
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

  // sdk更新时间
  String updateTime = '';

  // 排序
  int order = 0;

  // 创建时间
  @Property(type: PropertyType.date)
  DateTime createAt = DateTime.now();

  // 更新时间
  @Property(type: PropertyType.date)
  DateTime updateAt = DateTime.now();

  Environment();

  Environment.c({
    required this.path,
    required this.version,
    required this.channel,
    required this.gitUrl,
    required this.frameworkReversion,
    required this.engineReversion,
    required this.dartVersion,
    required this.devToolsVersion,
    required this.order,
    required this.updateTime,
    required this.createAt,
    required this.updateAt,
  });

  Environment.create({
    required this.path,
    required this.version,
    required this.channel,
    required this.gitUrl,
    required this.frameworkReversion,
    required this.engineReversion,
    required this.dartVersion,
    required this.devToolsVersion,
    required this.updateTime,
  });

  Environment.createImport(this.path);

  // 获取环境信息标题
  @Transient()
  String get title => 'Flutter · $version · $channel';

  Environment copyWith({
    String? path,
    String? version,
    String? channel,
    String? gitUrl,
    String? frameworkReversion,
    String? engineReversion,
    String? dartVersion,
    String? devToolsVersion,
    int? order,
    String? updateTime,
    DateTime? updateAt,
    DateTime? createAt,
  }) {
    return Environment.c(
      path: path ?? this.path,
      version: version ?? this.version,
      channel: channel ?? this.channel,
      gitUrl: gitUrl ?? this.gitUrl,
      frameworkReversion: frameworkReversion ?? this.frameworkReversion,
      engineReversion: engineReversion ?? this.engineReversion,
      dartVersion: dartVersion ?? this.dartVersion,
      devToolsVersion: devToolsVersion ?? this.devToolsVersion,
      order: order ?? this.order,
      updateTime: updateTime ?? this.updateTime,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  @override
  int get hashCode =>
      id.hashCode &
      path.hashCode &
      version.hashCode &
      channel.hashCode &
      gitUrl.hashCode &
      frameworkReversion.hashCode &
      engineReversion.hashCode &
      dartVersion.hashCode &
      devToolsVersion.hashCode &
      updateTime.hashCode &
      updateAt.hashCode &
      createAt.hashCode &
      order.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Environment &&
      id == other.id &&
      path == other.path &&
      version == other.version &&
      channel == other.channel &&
      gitUrl == other.gitUrl &&
      frameworkReversion == other.frameworkReversion &&
      engineReversion == other.engineReversion &&
      dartVersion == other.dartVersion &&
      devToolsVersion == other.devToolsVersion &&
      updateTime == other.updateTime &&
      updateAt == other.updateAt &&
      createAt == other.createAt &&
      order == other.order;
}
