import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/platform/android.dart';
import 'package:flutter_manager/page/detail/platform/ios.dart';
import 'package:flutter_manager/page/detail/platform/linux.dart';
import 'package:flutter_manager/page/detail/platform/macos.dart';
import 'package:flutter_manager/page/detail/platform/web.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/page/detail/platform/windows.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/dialog/project_asset.dart';
import 'package:flutter_manager/widget/dialog/project_build.dart';
import 'package:flutter_manager/widget/dialog/project_font.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/dialog/project_label.dart';
import 'package:flutter_manager/widget/dialog/project_logo.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/environment_badge.dart';
import 'package:flutter_manager/widget/keep_alive.dart';
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
                    create: (_) => PlatformProvider(project),
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
    final provider = context.read<ProjectDetailPageProvider>();
    final color = provider.project?.getColor();
    final hasColor = color != Colors.transparent;
    final themeProvider = context.read<ThemeProvider>();
    final brightness = themeProvider.getBrightness(context);
    return DefaultTabController(
      length: PlatformType.values.length,
      child: NestedScrollView(
        controller: provider.scrollController,
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
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
              flexibleSpace: FlexibleSpaceBar(
                background: Card(
                  child: Container(
                    color: hasColor ? color?.withOpacity(0.2) : null,
                    child: Row(
                      children: [
                        Expanded(child: _buildAppBarProjectInfo(context)),
                        _buildAppBarActions(context),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                splashBorderRadius: BorderRadius.circular(4),
                tabs: provider.platformMap.keys.map((e) {
                  return Tab(text: e.name);
                }).toList(),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: provider.platformMap.values.toList(),
        ),
      ),
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
    final platforms = provider.getPlatforms(context);
    return ListTile(
      isThreeLine: true,
      title: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromWidth(220)),
            child: Text(project.label,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          _buildEnvironmentBadge(project),
          const SizedBox(width: 4),
          IconButton(
            iconSize: 16,
            icon: const Icon(Icons.edit),
            visualDensity: VisualDensity.compact,
            onPressed: () => ProjectImportDialog.show(context, project: project)
                .then(provider.updateProject),
          ),
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.path,
              maxLines: 1, style: bodyStyle, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
            ),
            child: Wrap(
              spacing: 6,
              children: List.generate(platforms.length, (i) {
                final label = platforms[i].name;
                return RawChip(
                  label: Text(label),
                  padding: EdgeInsets.zero,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                );
              }),
            ),
          ),
        ],
      ),
      leading: Image.file(
        File(project.logo),
        width: 55,
        height: 55,
      ),
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
          tooltip: 'Asset管理',
          icon: const Icon(Icons.assessment_outlined),
          onPressed: () => _assetManager(context, project),
        ),
        IconButton.outlined(
          tooltip: '字体管理',
          icon: const Icon(Icons.font_download_outlined),
          onPressed: () => _fontManager(context, project),
        ),
        IconButton.outlined(
          tooltip: '打开项目目录',
          icon: const Icon(Icons.open_in_browser_rounded),
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
    return Selector<ProjectDetailPageProvider, bool>(
      selector: (_, provider) => provider.isScrollTop,
      builder: (_, isScrollTop, __) {
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: !isScrollTop
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildScrollActions(context),
          secondChild: _buildScrollTopActions(context),
        );
      },
    );
  }

  // 构建标题栏默认操作按钮
  Widget _buildScrollActions(BuildContext context) {
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    if (project == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            label: const Text('项目名'),
            icon: const Icon(Icons.edit_attributes_rounded),
            onPressed: () => _replaceLabels(context, project),
          ),
          TextButton.icon(
            label: const Text('图标'),
            onPressed: () => _replaceLogos(context, project),
            icon: const Icon(Icons.imagesearch_roller_rounded),
          ),
        ],
      ),
    );
  }

  // 构建滚动到顶部后的操作按钮
  Widget _buildScrollTopActions(BuildContext context) {
    final provider = context.read<ProjectDetailPageProvider>();
    final project = provider.project;
    final borderRadius = BorderRadius.circular(8);
    if (project == null) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: Image.file(
            File(project.logo),
            fit: BoxFit.cover,
            width: 30,
            height: 30,
          ),
        ),
        const SizedBox(width: 14),
        Text(project.label),
        const SizedBox(width: 8),
        _buildEnvironmentBadge(project),
        const Spacer(),
        TextButton.icon(
          label: const Text('打包'),
          icon: const Icon(Icons.build),
          onPressed: () => ProjectBuildDialog.show(context, project: project),
        ),
      ],
    );
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

  // 替换别名
  void _replaceLabels(BuildContext context, Project project) {
    final provider = context.read<PlatformProvider>();
    ProjectLabelDialog.show(
      context,
      platformLabelMap: provider.getLabelMap(context),
    ).then((result) {
      if (result == null) return;
      Loading.show(context,
          loadFuture: provider.updateLabels(project.path, result));
    });
  }

  // 替换图标
  void _replaceLogos(BuildContext context, Project project) {
    final provider = context.read<PlatformProvider>();
    final logoMap = provider.getLogoMap(context);
    ProjectLogoDialog.show(context, platformLogoMap: logoMap).then((result) {
      if (result == null) return;
      final controller = StreamController<double>();
      final total = logoMap.entries.fold<int>(0, (p, e) {
        if (!result.platforms.contains(e.key)) return p;
        return p + e.value.length;
      });
      Loading.show(context,
          dismissible: false,
          progressStream: controller.stream,
          loadFuture: provider.updateLogos(
            project.path,
            result,
            progressCallback: (count, _) {
              controller.add(count / total);
            },
          ));
    });
  }

  // Asset管理
  void _assetManager(BuildContext context, Project project) {
    final provider = context.read<PlatformProvider>();
    ProjectAssetDialog.show(context);
  }

  // 字体管理
  void _fontManager(BuildContext context, Project project) {
    final provider = context.read<PlatformProvider>();
    ProjectFontDialog.show(context);
  }
}

/*
* 项目详情页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPageProvider extends BaseProvider {
  // 缓存项目信息
  Project? _project;

  // 项目信息
  Project? get project => _project;

  // 头部内容高度
  final headerHeight = 200.0;

  // 判断当前是否已经滚动到顶部
  bool get isScrollTop => scrollController.offset >= headerHeight;

  // 滚动控制器
  final scrollController = ScrollController();

  // 项目平台对照表
  final platformMap = <PlatformType, Widget>{
    PlatformType.android: const KeepAliveWrapper(
      child: ProjectPlatformAndroidPage(),
    ),
    PlatformType.ios: const KeepAliveWrapper(
      child: ProjectPlatformIosPage(),
    ),
    PlatformType.web: const KeepAliveWrapper(
      child: ProjectPlatformWebPage(),
    ),
    PlatformType.macos: const KeepAliveWrapper(
      child: ProjectPlatformMacosPage(),
    ),
    PlatformType.windows: const KeepAliveWrapper(
      child: ProjectPlatformWindowsPage(),
    ),
    PlatformType.linux: const KeepAliveWrapper(
      child: ProjectPlatformLinuxPage(),
    ),
  };

  ProjectDetailPageProvider(BuildContext context) {
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
    // 根据当前项目的平台排序重新排序平台表
    final platformSort = context.read<ProjectProvider>().platformSort;
    for (var e in platformSort) {
      final widget = platformMap.remove(e);
      if (widget != null) platformMap[e] = widget;
    }
  }

  // 获取支持的平台列表
  List<PlatformType> getPlatforms(BuildContext context) {
    if (project == null) return [];
    final platforms = ProjectTool.getPlatforms(project!.path);
    // 根据当前项目的平台排序重新排序平台表
    final platformSort = context.read<ProjectProvider>().platformSort;
    for (var e in platformSort) {
      if (!platforms.contains(e)) continue;
      platforms.remove(e);
      platforms.add(e);
    }
    return platforms;
  }

  // 更新项目信息
  void updateProject(Project? project) {
    if (project == null) return;
    _project = project;
    notifyListeners();
  }
}
