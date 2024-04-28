import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/page/detail/appbar.dart';
import 'package:flutter_manager/page/detail/platform/android.dart';
import 'package:flutter_manager/page/detail/platform/ios.dart';
import 'package:flutter_manager/page/detail/platform/linux.dart';
import 'package:flutter_manager/page/detail/platform/macos.dart';
import 'package:flutter_manager/page/detail/platform/web.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/page/detail/platform/windows.dart';
import 'package:flutter_manager/page/detail/tabbar.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情页
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPage extends ProviderPage {
  const ProjectDetailPage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) => ProjectDetailPageProvider(context),
        ),
        ChangeNotifierProxyProvider<ProjectDetailPageProvider,
            PlatformProvider>(
          create: (_) => PlatformProvider(context, null),
          update: (_, provider, platformProvider) {
            if (provider.project != platformProvider?.project) {
              return PlatformProvider(context, provider.project?.copyWith());
            }
            return platformProvider!;
          },
        ),
      ];

  @override
  Widget buildPage(BuildContext context) {
    final project = context.watch<ProjectDetailPageProvider>().project;
    return Scaffold(
      body: EmptyBoxView(
        hint: '项目不存在',
        isEmpty: project == null,
        builder: (_, __) {
          if (project == null) return const SizedBox();
          return _buildContent(context, project);
        },
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context, Project project) {
    final provider = context.read<ProjectDetailPageProvider>();
    return Selector<PlatformProvider, List<PlatformType>>(
      selector: (_, provider) => provider.platformList,
      builder: (_, platforms, __) {
        return DefaultTabController(
          length: range(platforms.length, 1, PlatformType.values.length),
          child: NestedScrollView(
            controller: provider.scrollController,
            headerSliverBuilder: (_, __) =>
                [_buildAppBar(context, platforms, project)],
            body: _buildTabBarView(context, platforms),
          ),
        );
      },
    );
  }

  // 构建AppBar
  Widget _buildAppBar(
      BuildContext context, List<PlatformType> platforms, Project project) {
    final provider = context.read<ProjectDetailPageProvider>();
    return Selector<ProjectDetailPageProvider, bool>(
      selector: (_, provider) => provider.isScrollTop,
      builder: (_, isScrollTop, __) {
        return ProjectDetailAppBar(
          project: project,
          isCollapsed: isScrollTop,
          bottom: _buildTabBar(context, platforms),
          onProjectEdit: () => showProjectImport(
            context,
            project: project,
          ).then(provider.updateProject),
        );
      },
    );
  }

  // 构建TabBar
  PreferredSize _buildTabBar(
      BuildContext context, List<PlatformType> platforms) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ProjectDetailTabBar(
        platforms: platforms,
      ),
    );
  }

  // 构建TabBarView
  Widget _buildTabBarView(BuildContext context, List<PlatformType> platforms) {
    final provider = context.read<ProjectDetailPageProvider>();
    final views = platforms.map(provider.getPlatformView).toList();
    return TabBarView(children: [
      ...views,
      if (views.isEmpty)
        const EmptyBoxView(
          isEmpty: true,
          hint: '暂无平台',
        ),
    ]);
  }
}

/*
* 项目详情页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPageProvider extends BaseProvider {
  // 头部内容高度
  final headerHeight = 165.0;

  // 缓存项目信息
  Project? _project;

  // 项目信息
  Project? get project => _project;

  // 判断当前是否已经滚动到顶部
  bool get isScrollTop => scrollController.offset >= headerHeight;

  // 滚动控制器
  final scrollController = ScrollController();

  // 平台对照表
  final _platformMap = const {
    PlatformType.android: ProjectPlatformAndroidView(),
    PlatformType.ios: ProjectPlatformIosView(),
    PlatformType.web: ProjectPlatformWebView(),
    PlatformType.macos: ProjectPlatformMacosView(),
    PlatformType.windows: ProjectPlatformWindowsView(),
    PlatformType.linux: ProjectPlatformLinuxView(),
  };

  // 根据平台类型获取对应的页面
  Widget getPlatformView(PlatformType platform) => _platformMap[platform]!;

  ProjectDetailPageProvider(super.context) {
    // 获取项目信息
    _project = GoRouterState.of(context).extra as Project?;
    // 监听滚动状态
    bool scrollTop = false;
    scrollController.addListener(() {
      if (scrollTop != isScrollTop) {
        scrollTop = isScrollTop;
        notifyListeners();
      }
    });
  }

  // 更新项目信息
  void updateProject(Project? project) {
    if (project == null) return;
    _project = project;
    notifyListeners();
  }
}
