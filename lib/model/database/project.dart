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

  // 项目颜色
  int color = Colors.transparent.value;

  // 是否订到顶部
  bool pinned = false;

  // 项目排序
  int order = 0;

  // 创建时间
  DateTime createAt = DateTime.now();

  // 更新时间
  DateTime updateAt = DateTime.now();

  // 获取颜色
  Color getColor([double opacity = 1]) => Color(color).withOpacity(opacity);
}
