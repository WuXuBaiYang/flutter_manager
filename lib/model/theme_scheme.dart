import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/model.dart';

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

  ThemeSchemeModel.fromScheme(this.scheme,
      {required FlexSchemeColor schemeColor})
      : primary = schemeColor.primary;

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSchemeModel &&
          runtimeType == other.runtimeType &&
          scheme == other.scheme;

  @override
  int get hashCode => scheme.hashCode;
}
