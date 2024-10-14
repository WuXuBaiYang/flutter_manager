import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:jtech_base/jtech_base.dart';

@Entity()
class Project {
  int id = 0;

  // 项目名(自定义)
  String label = '';

  // 项目图标(自定义)
  String logo = '';

  // 项目路径
  String path = '';

  // 项目颜色
  int color = Colors.transparent.value;

  // 是否订到顶部
  bool pinned = false;

  // 项目排序
  int order = 0;

  // 环境信息
  final environmentDB = ToOne<Environment>();

  // 创建时间
  @Property(type: PropertyType.date)
  DateTime createAt = DateTime.now();

  // 更新时间
  @Property(type: PropertyType.date)
  DateTime updateAt = DateTime.now();

  Project();

  Project.c({
    required this.label,
    required this.logo,
    required this.path,
    required this.color,
    required this.pinned,
    required this.order,
    required this.createAt,
    required this.updateAt,
    required Environment? environment,
  }) {
    environmentDB.target = environment;
  }

  Project.create({
    required this.label,
    required this.logo,
    required this.path,
    required this.pinned,
    required Color color,
    required Environment environment,
  }) : color = color.value {
    environmentDB.target = environment;
  }

  // 获取环境
  @Transient()
  Environment? get environment => environmentDB.target;

  // 设置环境
  @Transient()
  set environment(Environment? value) => environmentDB.target = value;

  // 获取环境id
  @Transient()
  int? get envId => environment?.id;

  // 获取颜色
  Color getColor([double opacity = 1]) {
    if (color == Colors.transparent.value) return Colors.transparent;
    return Color(color).withOpacity(opacity);
  }

  // 实现copyWith
  Project copyWith({
    String? label,
    String? logo,
    String? path,
    Color? color,
    bool? pinned,
    int? order,
    DateTime? createAt,
    DateTime? updateAt,
    Environment? environment,
  }) {
    return Project.c(
      label: label ?? this.label,
      logo: logo ?? this.logo,
      path: path ?? this.path,
      color: color?.value ?? this.color,
      pinned: pinned ?? this.pinned,
      order: order ?? this.order,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      environment: environment ?? this.environment,
    );
  }

  @override
  int get hashCode =>
      id.hashCode &
      label.hashCode &
      logo.hashCode &
      path.hashCode &
      environment.hashCode &
      color.hashCode &
      pinned.hashCode &
      order.hashCode &
      createAt.hashCode &
      updateAt.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Project &&
      id == other.id &&
      label == other.label &&
      logo == other.logo &&
      path == other.path &&
      environment == other.environment &&
      color == other.color &&
      pinned == other.pinned &&
      order == other.order &&
      createAt == other.createAt &&
      updateAt == other.updateAt;
}
