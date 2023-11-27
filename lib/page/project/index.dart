import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/widget/dialog/project.dart';
import 'package:flutter_manager/widget/image.dart';
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

  // 构建网格代理
  SliverGridDelegate get _gridDelegate =>
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 85,
      );

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
        return GridView.builder(
          shrinkWrap: true,
          itemCount: projects.length,
          gridDelegate: _gridDelegate,
          padding: const EdgeInsets.all(14),
          itemBuilder: (_, i) {
            final item = projects[i];
            final bodyStyle = Theme.of(context).textTheme.bodySmall;
            return Card(
              child: Container(
                color: item.getColor(0.2),
                child: ContextMenuRegion(
                  contextMenu: ContextMenu(
                    entries: [
                      MenuItem(
                        label: '置顶',
                        icon: Icons.push_pin_rounded,
                        onSelected: () => provider.pinned(item),
                      ),
                      MenuItem(
                        label: '编辑',
                        icon: Icons.edit,
                        onSelected: () =>
                            ProjectImportDialog.show(context, project: item),
                      ),
                      MenuItem(
                        label: '删除',
                        icon: Icons.delete,
                        onSelected: () => provider.deleteProject(item),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(item.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(item.path,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStyle?.copyWith(
                            color: bodyStyle.color?.withOpacity(0.4))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    trailing: IconButton(
                      iconSize: 18,
                      icon: const Icon(Icons.push_pin_outlined),
                      onPressed: () {},
                    ),
                    leading: ImageView.file(
                      File(item.logo),
                      size: 45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onTap: () {
                      /// TODO: 跳转到项目详情页
                    },
                    onLongPress: () {},
                  ),
                ),
              ),
            );
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
