import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/page/package/index.dart';
import 'package:flutter_manager/page/project/index.dart';
import 'package:flutter_manager/page/settings/index.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 创建路由表
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        project: (_) => const ProjectPage(),
        package: (_) => const PackagePage(),
        settings: (_) => const SettingsPage(),
      };

  // 首页
  static const String home = '/home';

  // 项目页
  static const String project = '/project';

  // 打包页
  static const String package = '/package';

  // 设置页
  static const String settings = '/settings';
}
