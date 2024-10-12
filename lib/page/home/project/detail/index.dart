import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

import 'appbar.dart';
import 'platform/android.dart';
import 'platform/ios.dart';
import 'platform/linux.dart';
import 'platform/macos.dart';
import 'platform/web.dart';
import 'platform/widgets/provider.dart';
import 'platform/windows.dart';
import 'tabbar.dart';

/*
* 项目详情页
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPage extends ProviderPage<ProjectDetailPageProvider> {
  ProjectDetailPage({super.key, super.state});

  @override
  ProjectDetailPageProvider createProvider(
          BuildContext context, GoRouterState? state) =>
      ProjectDetailPageProvider(context, state);

  @override
  List<SingleChildWidget> extensionProviders() => [
        ChangeNotifierProxyProvider<ProjectDetailPageProvider,
            PlatformProvider>(
          create: (context) => PlatformProvider(context, null),
          update: (context, provider, platformProvider) {
            if (provider.project != platformProvider?.project) {
              return PlatformProvider(context, provider.project?.copyWith());
            }
            return platformProvider!;
          },
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final project = pageProvider.project;
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
class ProjectDetailPageProvider extends PageProvider {
  // 头部内容高度
  final headerHeight = 165.0;

  // 滚动控制器
  final scrollController = ScrollController();

  // 根据平台类型获取对应的页面
  Widget getPlatformView(PlatformType platform) => switch (platform) {
        PlatformType.android => ProjectPlatformAndroidView(),
        PlatformType.ios => ProjectPlatformIosView(),
        PlatformType.web => ProjectPlatformWebView(),
        PlatformType.macos => ProjectPlatformMacosView(),
        PlatformType.windows => ProjectPlatformWindowsView(),
        PlatformType.linux => ProjectPlatformLinuxView(),
      };

  ProjectDetailPageProvider(super.context, super.state) {
    // 监听滚动状态
    scrollController.addListener(_updateScrollTop);
  }

  // 记录是否滚动到顶部状态
  bool _isScrollTop = false;

  // 判断当前是否已经滚动到顶部
  bool get isScrollTop => _isScrollTop;

  // 缓存项目信息
  late Project? _project = getExtra<Project>();

  // 项目信息
  Project? get project => _project;

  // 更新项目信息
  void updateProject(Project? project) {
    if (project == null) return;
    _project = project;
    notifyListeners();
  }

  // 更新滚动到顶部状态
  void _updateScrollTop() {
    final isScrollTop = scrollController.offset >= headerHeight;
    if (_isScrollTop == isScrollTop) return;
    _isScrollTop = isScrollTop;
    notifyListeners();
  }
}
