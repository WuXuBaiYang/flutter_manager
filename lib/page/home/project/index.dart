import 'package:flutter/material.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/dialog/environment/import_local.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/drop_file.dart';
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
      body: _buildDropArea(context),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.addProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建文件拖拽区域
  Widget _buildDropArea(BuildContext context) {
    final enable = context.watch<HomeProvider>().isCurrentIndex(0);
    return DropFileView(
      enable: enable,
      onDoneValidator: (paths) {
        return provider.dropDone(context, paths);
      },
      child: _buildContent(context),
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
              onEdit: (item) => showProjectImport(context, project: item),
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
          onEdit: (item) => showProjectImport(context, project: item),
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
      return showNoticeError(
        '缺少Flutter环境',
        actions: [
          TextButton(
            onPressed: context.setting.goEnvironment,
            child: Text('设置'),
          ),
        ],
      );
    }
    showProjectImport(context);
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

  // 文件拖拽完成
  Future<String?> dropDone(BuildContext context, List<String> paths) async {
    if (paths.isEmpty) return null;
    final provider = context.env;
    // 遍历路径集合，从路径中读取项目/环境信息
    final temp = (projects: <Project>[], environments: <Environment>[]);
    for (var e in paths) {
      final project = await ProjectTool.getProjectInfo(e);
      if (project != null) temp.projects.add(project);
      if (EnvironmentTool.isAvailable(e)) {
        temp.environments.add(Environment()..path = e);
      }
    }
    // 如果没有有效内容，直接返回
    if (temp.projects.isEmpty && temp.environments.isEmpty) return '无效内容！';
    await Future.forEach(temp.environments.map((e) {
      return showImportEnvLocal(context, env: e);
    }), (e) => e);
    if (!provider.hasEnvironment && temp.projects.isNotEmpty) {
      return '请先添加环境信息';
    }
    await Future.forEach(temp.projects.map((e) {
      return showProjectImport(context, project: e);
    }), (e) => e);
    return null;
  }
}
