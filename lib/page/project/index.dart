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
    return DropFileView(
      onEnterValidator: (_) async {
        final hasEnvironment =
            context.read<EnvironmentProvider>().hasEnvironment;
        return !hasEnvironment ? '请先导入Flutter环境！' : null;
      },
      onDoneValidator: (paths) async {
        if (!_checkEnvironment(context)) return null;
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
          isEmpty: !hasProject,
          hint: '添加项目或\n拖拽项目放在这里',
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
    final projects =
        (await Future.wait<Project?>(paths.map(ProjectTool.getProjectInfo)))
          ..removeWhere((e) => e == null);
    if (projects.isEmpty) return '项目无效！';
    await Future.forEach(projects.map((e) {
      return ProjectImportDialog.show(context, project: e);
    }), (e) => e);
    return null;
  }
}
