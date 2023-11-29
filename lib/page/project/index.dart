import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/project/project_list.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/dialog/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:desktop_drop/desktop_drop.dart';

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
  List<SingleChildWidget> get providers => [
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
        onPressed: () =>
            context.read<ProjectPageProvider>().addNewProject(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建文件拖拽区域
  Widget _buildDropArea(BuildContext context) {
    final provider = context.read<ProjectPageProvider>();
    return DropTarget(
      onDragExited: (_) => provider.dropExited(),
      onDragEntered: (_) => provider.dropEntered(context),
      onDragDone: (details) =>
          provider.dropDone(context, details.files.map((e) => e.path).toList()),
      child: Selector<ProjectPageProvider, ProjectDropStateTuple?>(
        selector: (_, provider) => provider.dropState,
        builder: (_, dropState, __) {
          final color =
              dropState?.warning == true ? Colors.red.withOpacity(0.25) : null;
          return Selector<ProjectProvider, bool>(
            selector: (_, provider) => provider.hasProject,
            builder: (_, hasProject, __) {
              final isEmpty = dropState != null || !hasProject;
              final message =
                  dropState?.message ?? (!hasProject ? '添加项目或\n拖拽项目放在这里' : '');
              return EmptyBoxView(
                color: color,
                hint: message,
                isEmpty: isEmpty,
                child: _buildContent(context),
              );
            },
          );
        },
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildPinnedProjects(context),
        Expanded(child: _buildProjects(context)),
      ],
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
              onDetail: (item) {
                /// TODO: 跳转项目详情页
              },
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
          onDetail: (item) {
            /// TODO: 跳转项目详情页
          },
        );
      },
    );
  }
}

// 项目拖拽状态元组
typedef ProjectDropStateTuple = ({bool warning, String message});

/*
* 项目列表页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class ProjectPageProvider extends ChangeNotifier {
  // 项目拖拽状态
  ProjectDropStateTuple? _dropState;

  // 获取项目拖拽状态
  ProjectDropStateTuple? get dropState => _dropState;

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

  // 添加新项目
  void addNewProject(BuildContext context, {Project? project}) {
    if (context.read<EnvironmentProvider>().hasEnvironment) {
      ProjectImportDialog.show(context, project: project);
    } else {
      SnackTool.showMessage(
        context,
        message: '缺少Flutter环境',
        action: SnackBarAction(
          label: '去设置',
          onPressed: context.read<SettingProvider>().goEnvironment,
        ),
      );
    }
  }

  // 更新拖拽状态
  void _updateDropState(bool warning, String message) {
    _dropState = (warning: warning, message: message);
    notifyListeners();
  }

  // 文件拖拽进入区域
  void dropEntered(BuildContext context) {
    if (dropState != null) return;
    final noEnvironment = !context.read<EnvironmentProvider>().hasEnvironment;
    _updateDropState(
        noEnvironment, noEnvironment ? '请先导入Flutter环境！' : '松开并导入项目');
  }

  // 文件拖拽完成
  Future<void> dropDone(BuildContext context, List<String> paths) async {
    if (paths.isEmpty) return;
    final projects =
        (await Future.wait<Project?>(paths.map(ProjectTool.getProjectInfo)))
          ..removeWhere((e) => e == null);
    if (projects.isEmpty) {
      _updateDropState(true, '项目无效！');
      await Future.delayed(const Duration(seconds: 1));
      return dropExited();
    }
    await Future.forEach(projects.map((e) {
      return ProjectImportDialog.show(context, project: e);
    }), (e) => e);
    dropExited();
  }

  // 文件拖拽退出区域
  void dropExited() {
    _dropState = null;
    notifyListeners();
  }
}
