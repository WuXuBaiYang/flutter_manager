import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/project/project_list.dart';
import 'package:flutter_manager/provider/project.dart';
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPinnedProjects(context),
            _buildProjects(context),
            const SizedBox(height: kToolbarHeight),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => ProjectImportDialog.show(context),
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
        return SizedBox();
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
          onPinned: (item) => provider.pinned(item),
          onDelete: (item) => provider.remove(item),
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
class ProjectPageProvider extends ChangeNotifier {}
