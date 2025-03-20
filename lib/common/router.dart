import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/home/project/detail/index.dart';
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
        GoRoute(
          path: '/',
          builder: (_, state) => HomePage(state: state),
          routes: [
            GoRoute(
              path: '/project/detail',
              builder: (_, state) => ProjectDetailPage(state: state),
            ),
          ],
        ),
      ];

  // 跳转首页
  void goHome() => push('/');

  // 跳转项目详情页
  Future<void> goProjectDetail(Project project) =>
      push('/project/detail', extra: project);
}

// 全局单例
final router = Router();
