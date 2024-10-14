import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:jtech_base/jtech_base.dart';

import 'project.dart';

@Entity()
class Package {
  int id = 0;

  // 输出包名
  String name = '';

  // 打包指令后缀
  String suffix = '';

  // 安装包备份地址(为空代表不执行备份)
  String? backupPath;

  // 打包失败异常日志
  String? error;

  // 打包用时
  @Transient()
  Duration? duration;

  // 打包状态
  @Transient()
  PackageStatus status = PackageStatus.none;

  // 打包平台
  @Transient()
  PlatformType platformType = PlatformType.android;

  // 项目信息
  final projectDB = ToOne<Project>();

  // 创建时间
  @Property(type: PropertyType.date)
  DateTime createAt = DateTime.now();

  // 更新时间
  @Property(type: PropertyType.date)
  DateTime updateAt = DateTime.now();

  Package();

  Package.c({
    required this.name,
    required this.suffix,
    required this.backupPath,
    required this.error,
    required this.duration,
    required this.status,
    required this.platformType,
    required this.createAt,
    required this.updateAt,
    required Project? project,
  }) {
    projectDB.target = project;
  }

  Package.create({
    required this.name,
    required this.suffix,
    required this.platformType,
    required Project project,
    this.backupPath,
  }) {
    projectDB.target = project;
  }

  // 获取数据库打包时间
  int get durationDB => duration?.inMilliseconds ?? 0;

  // 设置数据库打包时间
  set durationDB(int value) => duration = Duration(milliseconds: value);

  // 获取数据库打包状态
  int get statusDB => status.index;

  // 设置数据库打包状态
  set statusDB(int value) => status = PackageStatus.values[value];

  // 获取数据库平台类型
  int get platformTypeDB => platformType.index;

  // 设置数据库平台类型
  set platformTypeDB(int value) => platformType = PlatformType.values[value];

  // 获取项目对象
  @Transient()
  Project? get project => projectDB.target;

  // 获取项目ID
  @Transient()
  int? get projectId => project?.id;

  Package copyWith({
    String? name,
    String? suffix,
    String? backupPath,
    String? error,
    Duration? duration,
    PackageStatus? status,
    PlatformType? platformType,
    Project? project,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return Package.c(
      name: name ?? this.name,
      suffix: suffix ?? this.suffix,
      backupPath: backupPath ?? this.backupPath,
      error: error ?? this.error,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      platformType: platformType ?? this.platformType,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      project: project ?? this.project,
    );
  }

  @override
  int get hashCode =>
      id.hashCode &
      name.hashCode &
      suffix.hashCode &
      backupPath.hashCode &
      error.hashCode &
      duration.hashCode &
      status.hashCode &
      platformType.hashCode &
      project.hashCode &
      createAt.hashCode &
      updateAt.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Package &&
      other.id == id &&
      other.name == name &&
      other.suffix == suffix &&
      other.backupPath == backupPath &&
      other.error == error &&
      other.duration == duration &&
      other.status == status &&
      other.platformType == platformType &&
      other.project == project &&
      other.createAt == createAt &&
      other.updateAt == updateAt;
}

// 打包状态枚举
enum PackageStatus {
  prepare,
  building,
  success,
  fail,
  none,
}
