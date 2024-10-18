import 'package:flutter/material.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/widget/dialog/project/import.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

import 'project_list.dart';

/*
* 首页-项目分页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class HomeProjectView extends ProviderView<HomeProjectProvider> {
  HomeProjectView({super.key});

  @override
  HomeProjectProvider? createProvider(BuildContext context) =>
      HomeProjectProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.addProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Selector<ProjectProvider, bool>(
      selector: (_, provider) => provider.hasProject,
      builder: (_, hasProject, __) {
        return EmptyBoxView(
          hint: '添加或拖拽\n项目/环境目录',
          isEmpty: !hasProject,
          child: Column(
            children: [
              _buildPinnedProjects(context),
              Expanded(child: _buildProjects(context)),
            ],
          ),
        );
      },
    );
  }

  // 构建置顶项目集合
  Widget _buildPinnedProjects(BuildContext context) {
    return Selector<ProjectProvider, List<Project>>(
      shouldRebuild: (_, __) => true,
      selector: (_, provider) => provider.pinnedProjects,
      builder: (_, pinnedProjects, __) {
        if (pinnedProjects.isEmpty) return const SizedBox();
        return Card(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              const Size.fromHeight(190),
            ),
            child: ProjectGridView(
              projects: pinnedProjects,
              onPinned: context.project.togglePinned,
              onReorder: context.project.reorderPinned,
              onDelete: (item) => provider.removeProject(context, item),
              onEdit: (item) => showImportProject(context, project: item),
              onDetail: (item) async {
                await router.goProjectDetail(item);
                if (context.mounted) context.project.refresh();
              },
            ),
          ),
        );
      },
    );
  }

  // 构建项目集合
  Widget _buildProjects(BuildContext context) {
    final projectProvider = context.project;
    return Selector<ProjectProvider, List<Project>>(
      shouldRebuild: (_, __) => true,
      selector: (_, provider) => provider.projects,
      builder: (_, projects, __) {
        if (projects.isEmpty) return const SizedBox();
        return ProjectGridView(
          projects: projects,
          onReorder: projectProvider.reorder,
          onPinned: projectProvider.togglePinned,
          padding: const EdgeInsets.all(14).copyWith(
            bottom: kToolbarHeight + 24,
          ),
          onDetail: (item) async {
            await router.goProjectDetail(item);
            projectProvider.refresh();
          },
          onDelete: (item) => provider.removeProject(context, item),
          onEdit: (item) => showImportProject(context, project: item),
        );
      },
    );
  }
}

class HomeProjectProvider extends BaseProvider {
  HomeProjectProvider(super.context);

  // 添加项目
  void addProject() {
    if (!context.env.hasEnvironment) {
      showNoticeError(
        '缺少Flutter环境',
        actions: [
          TextButton(
            onPressed: context.setting.goEnvironment,
            child: Text('设置'),
          ),
        ],
      );
      return;
    }
    showImportProject(context);
  }

  // 移除项目
  void removeProject(BuildContext context, Project item) {
    final provider = context.project..remove(item);
    showNoticeSuccess(
      '${item.label} 项目已移除',
      actions: [
        TextButton(
          child: Text('撤销'),
          onPressed: () => provider.update(item),
        ),
      ],
    );
  }
}
