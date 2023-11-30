import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/dialog/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/environment_badge.dart';
import 'package:flutter_manager/widget/image.dart';
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
  List<SingleChildWidget> getProviders(BuildContext context) => [
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
            child: _buildContent(context),
          );
        },
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<ProjectDetailPageProvider>();
    return DefaultTabController(
      length: PlatformPath.values.length,
      child: NestedScrollView(
        controller: provider.scrollController,
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
              pinned: true,
              scrolledUnderElevation: 1,
              title: _buildAppBarTitle(context),
              expandedHeight: provider.headerHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: Card(
                  child: Row(
                    children: [
                      Expanded(child: _buildAppBarProjectInfo(context)),
                      _buildAppBarActions(context),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                tabs: PlatformPath.values.map((e) {
                  return Tab(text: e.name);
                }).toList(),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            height: 10000,
          ),
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
    final platforms = ProjectTool.getPlatforms(project.path);
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
          Wrap(
            spacing: 4,
            children: List.generate(platforms.length, (i) {
              final label = platforms[i].name;
              return RawChip(
                label: Text(label),
                padding: EdgeInsets.zero,
                labelStyle: Theme.of(context).textTheme.bodySmall,
              );
            }),
          ),
        ],
      ),
      leading: ImageView.file(File(project.logo), size: 55),
    );
  }

  // 构建标题栏操作按钮
  Widget _buildAppBarActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      direction: Axis.vertical,
      children: [
        TextButton(
          child: const Text('修改名称'),
          onPressed: () {},
        ),
        TextButton(
          child: const Text('修改图标'),
          onPressed: () {},
        ),
      ],
    );
  }

  // 构建标题栏标题
  Widget _buildAppBarTitle(BuildContext context) {
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
              ImageView.file(File(project.logo), size: 35),
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
class ProjectDetailPageProvider extends ProjectPlatformProvider {
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
  }

  // 更新项目信息
  void updateProject(Project? project) {
    if (project == null) return;
    _project = project;
    notifyListeners();
  }
}

/*
* 项目平台信息provider
* @author wuxubaiyang
* @Time 2023/11/30 18:48
*/
class ProjectPlatformProvider extends ChangeNotifier {
  // 获取项目信息
  Project? getProjectInfo(BuildContext context) =>
      context.read<ProjectDetailPageProvider>().project;
}
