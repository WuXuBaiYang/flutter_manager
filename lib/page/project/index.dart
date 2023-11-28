import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/project/project_list.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/dialog/project.dart';
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
      body: Column(
        children: [
          _buildPinnedProjects(context),
          Expanded(child: _buildProjects(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          if (context.read<EnvironmentProvider>().hasEnvironment) {
            ProjectImportDialog.show(context);
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
        },
      ),
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
              onReorder: provider.reorder,
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
}
