import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/package/index.dart';
import 'package:flutter_manager/page/project/index.dart';
import 'package:flutter_manager/page/settings/index.dart';
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

  // 首页
  final String home = 'home';
  final String homePath = '/home';

  // 项目
  final String project = 'project';
  final String projectPath = '/project';

  // 项目详情
  final String projectDetail = 'projectDetail';
  final String projectDetailPath = '/project/detail';

  // 打包
  final String package = 'package';
  final String packagePath = '/package';

  // 知识库
  final String knowledge = 'knowledge';
  final String knowledgePath = '/knowledge';

  // 设置页
  final String settings = 'settings';
  final String settingsPath = '/settings';

  @override
  List<RouteBase> get routes => [
        // 首页
        GoRoute(
          name: home,
          path: homePath,
          builder: (_, state) {
            return HomePage(state: state);
          },
        ),
        // 项目页
        GoRoute(
          name: project,
          path: projectPath,
          builder: (_, state) {
            return ProjectPage(state: state);
          },
        ),
        // 项目详情页
        GoRoute(
          name: projectDetail,
          path: projectDetailPath,
          builder: (_, state) {
            return ProjectDetailPage(state: state);
          },
        ),
        // 包管理页
        GoRoute(
          name: package,
          path: packagePath,
          builder: (_, state) {
            return PackagePage(state: state);
          },
        ),
        // 设置页
        GoRoute(
          name: settings,
          path: settingsPath,
          builder: (_, state) {
            return SettingsPage(state: state);
          },
        ),
      ];

  // 跳转首页
  void goHome() => routerConfig.pushNamed(home);

  // 跳转项目页
  void goProject() => routerConfig.pushNamed(project);

  // 跳转项目详情页
  Future<void> goProjectDetail(Project project) =>
      routerConfig.pushNamed(projectDetail, extra: project);

  // 跳转打包页
  void goPackage() => routerConfig.pushNamed(package);

  // 跳转知识库页
  void goKnowledge() => routerConfig.pushNamed(knowledge);

  // 跳转设置页
  void goSettings() => routerConfig.pushNamed(settings);
}

// 全局单例
final router = Router();
