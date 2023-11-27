import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/*
* 项目网格视图
* @author wuxubaiyang
* @Time 2023/11/27 20:19
*/
class ProjectGridView extends StatelessWidget {
  // 项目集合
  final List<Project> projects;

  // 是否可以置顶
  final bool pinned;

  const ProjectGridView({
    super.key,
    required this.projects,
    this.pinned = true,
  });

  // 构建网格代理
  SliverGridDelegate get _gridDelegate =>
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 85,
      );

  // 右键菜单
  ContextMenu get _contextMenu => ContextMenu(entries: const [
        MenuItem<int>(value: 0, label: '置顶', icon: Icons.push_pin_rounded),
        MenuItem<int>(value: 1, label: '编辑', icon: Icons.edit),
        MenuItem<int>(value: 2, label: '删除', icon: Icons.delete),
      ]);

  @override
  Widget build(BuildContext context) {
    return ReorderableGridView.builder(
      shrinkWrap: true,
      itemCount: projects.length,
      gridDelegate: _gridDelegate,
      padding: const EdgeInsets.all(14),
      onReorder: (oldIndex, newIndex) {},
      itemBuilder: (_, i) {
        final item = projects[i];
        return _buildProjectItem(item);
      },
    );
  }

  // 构建项目子项
  Widget _buildProjectItem(Project item) {
    return SizedBox();
  }
}
