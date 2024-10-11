import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/home/package/index.dart';
import 'package:flutter_manager/page/home/project/detail/index.dart';
import 'package:flutter_manager/page/home/project/index.dart';
import 'package:flutter_manager/page/home/settings/index.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 路由管理
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class Router extends BaseRouter {
  static final Router _instance = Router._internal();

  factory Router() => _instance;

  Router._internal();

  @override
  List<RouteBase> get routes => [
        // 首页
        GoRoute(
          name: 'home',
          path: '/',
          builder: (_, state) => HomePage(state: state),
        ),
        // 项目页
        GoRoute(
          name: 'homeProject',
          path: '/home/project',
          builder: (_, state) => ProjectPage(state: state),
        ),
        // 项目详情页
        GoRoute(
          name: 'homeProjectDetail',
          path: '/home/project/detail',
          builder: (_, state) => ProjectDetailPage(state: state),
        ),
        // 包管理页
        GoRoute(
          name: 'homePackage',
          path: '/home/package',
          builder: (_, state) => PackagePage(state: state),
        ),
        // 设置页
        GoRoute(
          name: 'homeSettings',
          path: '/home/settings',
          builder: (_, state) => SettingsPage(state: state),
        ),
      ];

  // 跳转首页
  void goHome() => routerConfig.pushNamed('home');

  // 跳转项目页
  void goProject() => routerConfig.pushNamed('homeProject');

  // 跳转项目详情页
  Future<void> goProjectDetail(Project project) =>
      routerConfig.pushNamed('homeProjectDetail', extra: project);

  // 跳转打包页
  void goPackage() => routerConfig.pushNamed('homePackage');

  // 跳转知识库页
  void goKnowledge() => routerConfig.pushNamed('homeKnowledge');

  // 跳转设置页
  void goSettings() => routerConfig.pushNamed('homeSettings');
}

// 全局单例
final router = Router();
