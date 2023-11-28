import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/widget/image.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/*
* 项目网格视图
* @author wuxubaiyang
* @Time 2023/11/27 20:19
*/
class ProjectGridView extends StatelessWidget {
  // 项目集合
  final List<Project> projects;

  // 置顶回调
  final ValueChanged<Project>? onPinned;

  // 编辑回调
  final ValueChanged<Project>? onEdit;

  // 删除回调
  final ValueChanged<Project>? onDelete;

  // 跳转详情页
  final ValueChanged<Project>? onDetail;

  const ProjectGridView({
    super.key,
    required this.projects,
    this.onEdit,
    this.onPinned,
    this.onDelete,
    this.onDetail,
  });

  // 构建网格代理
  SliverGridDelegate get _gridDelegate =>
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 85,
      );

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
        return _buildProjectItem(context, item);
      },
    );
  }

  // 右键菜单
  ContextMenu get _contextMenu => ContextMenu(entries: [
        MenuItem(value: onPinned, label: '置顶', icon: Icons.push_pin_rounded),
        MenuItem(value: onEdit, label: '编辑', icon: Icons.edit),
        MenuItem(value: onDelete, label: '删除', icon: Icons.delete),
      ]);

  // 构建项目子项
  Widget _buildProjectItem(BuildContext context, Project item) {
    var bodyStyle = Theme.of(context).textTheme.bodySmall;
    final color = bodyStyle?.color?.withOpacity(0.4);
    bodyStyle = bodyStyle?.copyWith(color: color);
    final borderRadius = BorderRadius.circular(4);
    const contentPadding = EdgeInsets.symmetric(horizontal: 14);
    return ContextMenuRegion(
      contextMenu: _contextMenu,
      onItemSelected: (c) => c?.call(item),
      child: Card(
        child: Container(
          color: item.getColor(0.2),
          child: ListTile(
            contentPadding: contentPadding,
            title: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.path,
              maxLines: 2,
              style: bodyStyle,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Transform.rotate(
              angle: item.pinned ? 90 : 0,
              child: IconButton(
                iconSize: 18,
                icon: const Icon(Icons.push_pin_outlined),
                onPressed: () => onPinned?.call(item),
              ),
            ),
            leading: ImageView.file(
              File(item.logo),
              size: 45,
              borderRadius: borderRadius,
            ),
            onTap: () => onDetail?.call(item),
          ),
        ),
      ),
    );
  }
}
