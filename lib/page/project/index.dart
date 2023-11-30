import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/project/project_list.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/dialog/environment.dart';
import 'package:flutter_manager/widget/dialog/project.dart';
import 'package:flutter_manager/widget/drop_file.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class ProjectPage extends BasePage {
  const ProjectPage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(create: (_) => ProjectPageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目'),
      ),
      body: _buildDropArea(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_checkEnvironment(context)) return;
          ProjectImportDialog.show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建文件拖拽区域
  Widget _buildDropArea(BuildContext context) {
    final provider = context.read<ProjectPageProvider>();
    final enable = context.watch<HomePageProvider>().isNavigationIndex(0);
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
    final provider = context.read<ProjectProvider>();
    return Selector<ProjectProvider, List<Project>>(
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
              onDelete: (item) => context
                  .read<ProjectPageProvider>()
                  .removeProject(context, item),
              onReorder: provider.reorderPinned,
              onPinned: provider.togglePinned,
              onEdit: (item) =>
                  ProjectImportDialog.show(context, project: item),
              onDetail: (item) => router.pushNamed(
                RoutePath.projectDetail,
                arguments: (project: item),
              )?.then((_) => provider.initialize()),
            ),
          ),
        );
      },
    );
  }

  // 构建项目集合
  Widget _buildProjects(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    return Selector<ProjectProvider, List<Project>>(
      selector: (_, provider) => provider.projects,
      builder: (_, projects, __) {
        if (projects.isEmpty) return const SizedBox();
        return ProjectGridView(
          projects: projects,
          onReorder: provider.reorder,
          onPinned: provider.togglePinned,
          onDelete: (item) =>
              context.read<ProjectPageProvider>().removeProject(context, item),
          padding: const EdgeInsets.all(14).copyWith(
            bottom: kToolbarHeight + 24,
          ),
          onEdit: (item) => ProjectImportDialog.show(context, project: item),
          onDetail: (item) => router.pushNamed(
            RoutePath.projectDetail,
            arguments: (project: item),
          )?.then((_) => provider.initialize()),
        );
      },
    );
  }

  // 检查环境是否存在
  bool _checkEnvironment(BuildContext context) {
    final hasEnvironment = context.read<EnvironmentProvider>().hasEnvironment;
    if (hasEnvironment) return true;
    SnackTool.showMessage(
      context,
      message: '缺少Flutter环境',
      action: SnackBarAction(
        label: '去设置',
        onPressed: context.read<SettingProvider>().goEnvironment,
      ),
    );
    return hasEnvironment;
  }
}

/*
* 项目列表页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class ProjectPageProvider extends ChangeNotifier {
  // 移除项目
  void removeProject(BuildContext context, Project item) {
    final provider = context.read<ProjectProvider>()..remove(item);
    SnackTool.showMessage(
      context,
      message: '${item.label} 项目已移除',
      action: SnackBarAction(
        label: '撤销',
        onPressed: () => provider.update(item),
      ),
    );
  }

  // 文件拖拽完成
  Future<String?> dropDone(BuildContext context, List<String> paths) async {
    if (paths.isEmpty) return null;
    final provider = context.read<EnvironmentProvider>();
    // 遍历路径集合，从路径中读取项目/环境信息
    final temp = (projects: <Project>[], environments: <Environment>[]);
    for (var e in paths) {
      final project = await ProjectTool.getProjectInfo(e);
      if (project != null) temp.projects.add(project);
      if (EnvironmentTool.isPathAvailable(e)) {
        temp.environments.add(Environment()..path = e);
      }
    }
    // 如果没有有效内容，直接返回
    if (temp.projects.isEmpty && temp.environments.isEmpty) return '无效内容！';
    await Future.forEach(temp.environments.map((e) {
      return EnvironmentImportDialog.show(context, environment: e);
    }), (e) => e);
    if (!provider.hasEnvironment && temp.projects.isNotEmpty) {
      return '请先添加环境信息';
    }
    await Future.forEach(temp.projects.map((e) {
      return ProjectImportDialog.show(context, project: e);
    }), (e) => e);
    return null;
  }
}
