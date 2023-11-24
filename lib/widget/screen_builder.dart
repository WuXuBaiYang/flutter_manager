import 'package:flutter/material.dart';

/*
* 屏幕类型构造器(mobile/tablet/tv/desktop)
* @author wuxubaiyang
* @Time 2023/11/20 15:48
*/
class ScreenTypeBuilder extends StatelessWidget {
  // 最大移动端屏幕尺寸
  static const double mobileMaxSize = 720;

  // 最大平板屏幕尺寸
  static const double padMaxSize = 1200;

  // 默认构造器
  final WidgetBuilder builder;

  // 移动端构造器
  final WidgetBuilder? mobile;

  // 平板构造器
  final WidgetBuilder? tablet;

  // 电视构造器
  final WidgetBuilder? tv;

  // web构造器
  final WidgetBuilder? web;

  // 桌面构造器
  final WidgetBuilder? desktop;

  const ScreenTypeBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.tv,
    this.web,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final builder = _selectBuilder(context, constraints.maxWidth);
        return (builder ?? this.builder)(context);
      },
    );
  }

  // 选择当前屏幕/平台类型构造器
  WidgetBuilder? _selectBuilder(BuildContext context, double maxSize) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        if (maxSize < mobileMaxSize) return mobile;
        if (maxSize < padMaxSize) return tablet;
        return tv;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return desktop;
      default:
        return builder;
    }
  }
}
