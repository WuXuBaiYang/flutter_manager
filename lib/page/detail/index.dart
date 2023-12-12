import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/model/environment.dart';
import 'package:flutter_manager/model/project.dart';
import 'package:flutter_manager/page/detail/platform/android.dart';
import 'package:flutter_manager/page/detail/platform/ios.dart';
import 'package:flutter_manager/page/detail/platform/linux.dart';
import 'package:flutter_manager/page/detail/platform/macos.dart';
import 'package:flutter_manager/page/detail/platform/web.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/page/detail/platform/windows.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/dialog/project_asset.dart';
import 'package:flutter_manager/widget/dialog/project_build.dart';
import 'package:flutter_manager/widget/dialog/project_font.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/dialog/project_label.dart';
import 'package:flutter_manager/widget/dialog/project_logo.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/environment_badge.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 项目详情页路由传参元组
typedef ProjectDetailRouteTuple = ({Project project});

/*
* 项目详情页
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPage extends BasePage {
  const ProjectDetailPage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) => ProjectDetailPageProvider(context),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: Selector<ProjectDetailPageProvider, Project?>(
        selector: (_, provider) => provider.project,
        builder: (_, project, __) {
          return EmptyBoxView(
            hint: '项目不存在',
            isEmpty: project == null,
            child: project != null
                ? ChangeNotifierProvider(
                    lazy: false,
                    create: (_) => PlatformProvider(context, project),
                    builder: (context, _) => _buildContent(context),
                  )
                : const SizedBox(),
          );
        },
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final brightness = context.read<ThemeProvider>().brightness;
    final provider = context.read<ProjectDetailPageProvider>();
    final color = provider.project?.getColor();
    return Selector<PlatformProvider, List<PlatformType>>(
      selector: (_, provider) => provider.platformList,
      builder: (_, platforms, __) {
        return DefaultTabController(
          length: range(platforms.length, 1, PlatformType.values.length),
          child: NestedScrollView(
            controller: provider.scrollController,
            headerSliverBuilder: (_, __) =>
                [_buildAppBar(context, platforms, brightness, color)],
            body: _buildTabBarView(context, platforms),
          ),
        );
      },
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

  // 构建AppBar
  Widget _buildAppBar(BuildContext context, List<PlatformType> platforms,
      Brightness brightness, Color? color) {
    final provider = context.read<ProjectDetailPageProvider>();
    final hasColor = color != Colors.transparent;
    return SliverAppBar(
      pinned: true,
      titleSpacing: 6,
      automaticallyImplyLeading: false,
      expandedHeight: provider.headerHeight,
      scrolledUnderElevation: hasColor ? 8 : 1,
      surfaceTintColor: hasColor ? color : null,
      title: buildStatusBar(context, brightness, actions: [
        const BackButton(),
        Expanded(child: _buildAppBarTitle(context)),
      ]),
      flexibleSpace: _buildFlexibleSpace(
          context, hasColor ? color?.withOpacity(0.2) : null),
      bottom: _buildTabBar(context, platforms),
    );
  }

  // 构建FlexibleSpace
  Widget _buildFlexibleSpace(BuildContext context, Color? color) {
    return FlexibleSpaceBar(
      background: Card(
        child: Container(
          color: color,
          child: Row(children: [
            Expanded(child: _buildAppBarProjectInfo(context)),
            _buildAppBarActions(context),
          ]),
        ),
      ),
    );
  }

  // 构建TabBar
  PreferredSize _buildTabBar(
      BuildContext context, List<PlatformType> platforms) {
    final tabs = platforms.map((e) => Tab(text: e.name)).toList();
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Row(children: [
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          splashBorderRadius: BorderRadius.circular(4),
          tabs: [
            ...tabs,
            if (tabs.isEmpty) const Tab(text: '暂无平台'),
          ],
        ),
        Expanded(child: _buildPlatformActions(context, platforms)),
        const SizedBox(width: 8),
      ]),
    );
  }

  // 构建标题栏项目信息
  Widget _buildAppBarProjectInfo(BuildContext context) {
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    if (project == null) return const SizedBox();
    var bodyStyle = Theme.of(context).textTheme.bodySmall;
    final color = bodyStyle?.color?.withOpacity(0.4);
    bodyStyle = bodyStyle?.copyWith(color: color);
    return ListTile(
      isThreeLine: true,
      title: Row(children: [
        ConstrainedBox(
          constraints: BoxConstraints.loose(const Size.fromWidth(220)),
          child:
              Text(project.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        _buildEnvironmentBadge(project),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 14,
          icon: const Icon(Icons.edit),
          visualDensity: VisualDensity.compact,
          onPressed: () => ProjectImportDialog.show(context, project: project)
              .then(provider.updateProject),
        ),
      ]),
      leading: Image.file(File(project.logo), width: 55, height: 55),
      subtitle: Text(project.path,
          maxLines: 1, style: bodyStyle, overflow: TextOverflow.ellipsis),
    );
  }

  // 构建标题栏操作按钮
  Widget _buildAppBarActions(BuildContext context) {
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    if (project == null) return const SizedBox();
    return Row(
      children: [
        IconButton.outlined(
          iconSize: 20,
          tooltip: 'Asset管理',
          icon: const Icon(Icons.assessment_outlined),
          onPressed: () {
            /// TODO: Asset管理
            ProjectAssetDialog.show(context);
          },
        ),
        IconButton.outlined(
          iconSize: 20,
          tooltip: '字体管理',
          icon: const Icon(Icons.font_download_outlined),
          onPressed: () {
            /// TODO: 字体管理
            ProjectFontDialog.show(context);
          },
        ),
        IconButton.outlined(
          iconSize: 20,
          tooltip: '打开项目目录',
          icon: const Icon(Icons.file_open_outlined),
          onPressed: () => Tool.openLocalPath(project.path),
        ),
        FilledButton.icon(
          label: const Text('打包'),
          icon: const Icon(Icons.build),
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(const Size.fromHeight(55)),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            textStyle: MaterialStateProperty.all(
                Theme.of(context).textTheme.bodyLarge),
          ),
          onPressed: () => ProjectBuildDialog.show(context, project: project),
        ),
      ].expand((e) => [e, const SizedBox(width: 14)]).toList(),
    );
  }

  // 构建标题栏标题
  Widget _buildAppBarTitle(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    if (project == null) return const SizedBox();
    return Selector<ProjectDetailPageProvider, bool>(
      selector: (_, provider) => provider.isScrollTop,
      builder: (_, isScrollTop, __) {
        return AnimatedOpacity(
          opacity: isScrollTop ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: borderRadius,
                child: Image.file(File(project.logo),
                    fit: BoxFit.cover, width: 30, height: 30),
              ),
              const SizedBox(width: 14),
              Text(project.label),
              const SizedBox(width: 8),
              _buildEnvironmentBadge(project),
            ],
          ),
        );
      },
    );
  }

  // 构建平台聚合操作项
  Widget _buildPlatformActions(
      BuildContext context, List<PlatformType> platforms) {
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    if (project == null) return const SizedBox();
    final platformProvider = context.read<PlatformProvider>();
    final createPlatforms =
        PlatformType.values.where((e) => !platforms.contains(e)).toList();
    return Row(children: [
      if (createPlatforms.isNotEmpty)
        PopupMenuButton(
          iconSize: 20,
          tooltip: '创建平台',
          icon: const Icon(Icons.add),
          onSelected: (v) =>
              platformProvider.createPlatform(project, v).loading(context),
          itemBuilder: (_) => createPlatforms
              .map((e) => PopupMenuItem(
                    value: e,
                    child: Text(e.name),
                  ))
              .toList(),
        ),
      const Spacer(),
      Tooltip(
        message: '替换项目名',
        child: TextButton.icon(
          label: const Text('名称'),
          icon: const Icon(Icons.edit_attributes_rounded, size: 18),
          onPressed: () => ProjectLabelDialog.show(
            context,
            platformLabelMap: platformProvider.labelMap,
          ).then((result) {
            if (result == null) return;
            platformProvider
                .updateLabels(project.path, result)
                .loading(context, dismissible: false);
          }),
        ),
      ),
      Tooltip(
        message: '替换图标',
        child: TextButton.icon(
          label: const Text('图标'),
          onPressed: () => ProjectLogoDialog.show(
            context,
            platformLogoMap: platformProvider.logoMap,
          ).then((result) {
            if (result == null) return;
            final controller = StreamController<double>();
            platformProvider
                .updateLogos(project.path, result, controller: controller)
                .loading(context,
                    inputStream: controller.stream, dismissible: false);
          }),
          icon: const Icon(Icons.imagesearch_roller_rounded, size: 18),
        ),
      ),
    ]);
  }

  // 构建项目环境标签
  Widget _buildEnvironmentBadge(Project item) {
    return FutureProvider<Environment?>(
      initialData: null,
      create: (_) => database.getEnvironmentById(item.envId),
      builder: (context, _) {
        final environment = context.watch<Environment?>();
        if (environment == null) return const SizedBox();
        return EnvironmentBadge(environment: environment);
      },
    );
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
    PlatformType.android: ProjectPlatformAndroidPage(),
    PlatformType.ios: ProjectPlatformIosPage(),
    PlatformType.web: ProjectPlatformWebPage(),
    PlatformType.macos: ProjectPlatformMacosPage(),
    PlatformType.windows: ProjectPlatformWindowsPage(),
    PlatformType.linux: ProjectPlatformLinuxPage(),
  };

  // 根据平台类型获取对应的页面
  Widget getPlatformView(PlatformType platform) => _platformMap[platform]!;

  ProjectDetailPageProvider(super.context) {
    // 获取项目信息
    final arguments = router.findTuple<ProjectDetailRouteTuple>(context);
    _project = arguments?.project;
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
