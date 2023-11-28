import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/model.dart';
import 'package:flutter_manager/provider/theme.dart';

/*
* 主题配色方案数据对象
* @author wuxubaiyang
* @Time 2023/11/21 10:42
*/
class ThemeSchemeModel extends BaseModel {
  // 配色方案
  final FlexScheme scheme;

  // 主题色
  final Color primary;

  // 次级主题色
  final Color secondary;

  // 获取配色方案名称
  String get label => scheme.label;

  ThemeSchemeModel.fromScheme(this.scheme,
      {required FlexSchemeColor schemeColor})
      : primary = schemeColor.primary,
        secondary = schemeColor.secondary;

  // 主题对比
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSchemeModel &&
          runtimeType == other.runtimeType &&
          scheme == other.scheme &&
          primary == other.primary &&
          secondary == other.secondary;

  // 主题哈希值
  @override
  int get hashCode => scheme.hashCode ^ primary.hashCode ^ secondary.hashCode;
}
