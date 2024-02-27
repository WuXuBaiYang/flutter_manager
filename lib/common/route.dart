import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/package/index.dart';
import 'package:flutter_manager/page/project/index.dart';
import 'package:flutter_manager/page/settings/index.dart';
import 'package:go_router/go_router.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 创建路由表
  static GoRouter get routes => GoRouter(routes: [
        // 首页
        GoRoute(path: home, builder: (_, __) => const HomePage()),
        // 项目页
        GoRoute(path: project, builder: (_, __) => const ProjectPage()),
        // 项目详情页
        GoRoute(
            path: projectDetail, builder: (_, __) => const ProjectDetailPage()),
        // 包管理页
        GoRoute(path: package, builder: (_, __) => const PackagePage()),
        // 设置页
        GoRoute(path: settings, builder: (_, __) => const SettingsPage()),
      ]);

  // 首页
  static const String home = '/';

  // 项目页
  static const String project = '/project';

  // 项目详情页
  static const String projectDetail = '/project/detail';

  // 打包页
  static const String package = '/package';

  // 知识库
  static const String knowledge = '/knowledge';

  // 设置页
  static const String settings = '/settings';
}
