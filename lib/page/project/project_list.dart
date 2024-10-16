import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/custom_context_menu_region.dart';
import 'package:flutter_manager/widget/environment_badge.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

// 确认删除回调
typedef ProjectConfirmDismissCallback = Future<bool?> Function(Project item);

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

  // 位置改变回调
  final ReorderCallback? onReorder;

  // 确认删除回调
  final ProjectConfirmDismissCallback? confirmDismiss;

  // 内间距
  final EdgeInsetsGeometry padding;

  const ProjectGridView({
    super.key,
    required this.projects,
    this.onEdit,
    this.onPinned,
    this.onDelete,
    this.onDetail,
    this.onReorder,
    this.confirmDismiss,
    this.padding = const EdgeInsets.all(14),
  });

  // 构建网格代理
  SliverGridDelegate get _gridDelegate =>
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 80,
      );

  // 右键菜单
  ContextMenu get _contextMenu => ContextMenu(entries: [
        MenuItem(value: onPinned, label: '置顶', icon: Icons.push_pin_rounded),
        MenuItem(value: onEdit, label: '编辑', icon: Icons.edit),
        MenuItem(value: onDelete, label: '删除', icon: Icons.delete),
      ]);

  @override
  Widget build(BuildContext context) {
    return ReorderableGridView.builder(
      shrinkWrap: true,
      padding: padding,
      itemCount: projects.length,
      gridDelegate: _gridDelegate,
      onReorder: (oldIndex, newIndex) {
        return onReorder?.call(oldIndex, newIndex);
      },
      dragWidgetBuilderV2: DragWidgetBuilderV2(
        isScreenshotDragWidget: false,
        builder: (_, child, __) => child,
      ),
      itemBuilder: (_, i) {
        final item = projects[i];
        return _buildItem(context, item);
      },
    );
  }

  // 构建项目子项
  Widget _buildItem(BuildContext context, Project item) {
    return CustomContextMenuRegion(
      key: ValueKey(item.id),
      contextMenu: _contextMenu,
      onItemSelected: (c) => c?.call(item),
      child: Card(
        elevation: item.pinned ? 5 : null,
        child: Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete?.call(item),
          confirmDismiss: (_) =>
              confirmDismiss?.call(item) ?? Future.value(true),
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 14),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _buildItemContent(context, item),
        ),
      ),
    );
  }

  // 构建项目子项内容
  Widget _buildItemContent(BuildContext context, Project item) {
    var bodyStyle = Theme.of(context).textTheme.bodySmall;
    final color = bodyStyle?.color?.withOpacity(0.4);
    bodyStyle = bodyStyle?.copyWith(color: color);
    const contentPadding = EdgeInsets.symmetric(horizontal: 14);
    final borderRadius = BorderRadius.circular(8);
    const imageSize = Size.square(45);
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: item.getColor(0.2),
      child: ListTile(
        contentPadding: contentPadding,
        title: Row(children: [
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromWidth(105)),
            child:
                Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          _buildEnvironmentBadge(item),
        ]),
        subtitle: Text(item.path,
            maxLines: 2, style: bodyStyle, overflow: TextOverflow.ellipsis),
        leading: item.logo.isNotEmpty
            ? ClipRRect(
                borderRadius: borderRadius,
                child: Image.file(
                  File(item.logo),
                  fit: BoxFit.cover,
                  width: imageSize.width,
                  height: imageSize.height,
                ),
              )
            : SizedBox.fromSize(size: imageSize),
        trailing: Transform.rotate(
          angle: item.pinned ? 45 : 0,
          child: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.push_pin_outlined),
            onPressed: () => onPinned?.call(item),
          ),
        ),
        onTap: () => onDetail?.call(item),
      ),
    );
  }

  // 构建项目环境标签
  Widget _buildEnvironmentBadge(Project item) {
    final environment = database.getEnvironmentById(item.envId);
    if (environment == null) return const SizedBox();
    return EnvironmentBadge(environment: environment);
  }
}
