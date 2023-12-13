import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  // 项目名(自定义)
  String label = '';

  // 项目图标(自定义)
  String logo = '';

  // 项目路径
  @Index(unique: true, replace: true)
  String path = '';

  // 环境id
  int envId = -1;

  // 项目颜色
  int color = Colors.transparent.value;

  // 是否订到顶部
  bool pinned = false;

  // 项目排序
  int order = -1;

  // 创建时间
  DateTime createAt = DateTime.now();

  // 更新时间
  DateTime updateAt = DateTime.now();

  // 获取颜色
  Color getColor([double opacity = 1]) {
    if (color == Colors.transparent.value) return Colors.transparent;
    return Color(color).withOpacity(opacity);
  }

  // 实现copyWith
  Project copyWith({
    Id? id,
    String? label,
    String? logo,
    String? path,
    int? envId,
    int? color,
    bool? pinned,
    int? order,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return Project()
      ..id = id ?? this.id
      ..label = label ?? this.label
      ..logo = logo ?? this.logo
      ..path = path ?? this.path
      ..envId = envId ?? this.envId
      ..color = color ?? this.color
      ..pinned = pinned ?? this.pinned
      ..order = order ?? this.order
      ..createAt = createAt ?? this.createAt
      ..updateAt = updateAt ?? this.updateAt;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          logo == other.logo &&
          path == other.path &&
          envId == other.envId &&
          color == other.color &&
          pinned == other.pinned &&
          order == other.order &&
          createAt == other.createAt &&
          updateAt == other.updateAt;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      logo.hashCode ^
      path.hashCode ^
      envId.hashCode ^
      color.hashCode ^
      pinned.hashCode ^
      order.hashCode ^
      createAt.hashCode ^
      updateAt.hashCode;
}
