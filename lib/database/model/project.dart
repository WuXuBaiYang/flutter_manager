import 'package:flutter/material.dart';
import 'package:jtech_base/jtech_base.dart';

@Entity()
class Project {
  int id;

  // 项目名(自定义)
  String label;

  // 项目图标(自定义)
  String logo;

  // 项目路径
  String path;

  // 环境id
  int envId;

  // 项目颜色
  int color;

  // 是否订到顶部
  bool pinned;

  // 项目排序
  int order;

  // 创建时间
  @Property(type: PropertyType.date)
  DateTime createAt = DateTime.now();

  // 更新时间
  @Property(type: PropertyType.date)
  DateTime updateAt = DateTime.now();

  Project({
    this.id = 0,
    this.label = '',
    this.logo = '',
    this.path = '',
    this.envId = -1,
    this.color = 0,
    this.pinned = false,
    this.order = -1,
  });

  // 获取颜色
  Color getColor([double opacity = 1]) {
    if (color == Colors.transparent.value) return Colors.transparent;
    return Color(color).withOpacity(opacity);
  }

  // 实现copyWith
  Project copyWith({
    int? id,
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
  int get hashCode =>
      id.hashCode &
      label.hashCode &
      logo.hashCode &
      path.hashCode &
      envId.hashCode &
      color.hashCode &
      pinned.hashCode &
      order.hashCode &
      createAt.hashCode &
      updateAt.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Project) return false;
    return id == other.id &&
        label == other.label &&
        logo == other.logo &&
        path == other.path &&
        envId == other.envId &&
        color == other.color &&
        pinned == other.pinned &&
        order == other.order &&
        createAt == other.createAt &&
        updateAt == other.updateAt;
  }
}
