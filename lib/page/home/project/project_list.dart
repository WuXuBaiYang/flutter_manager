import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/context_menu_region.dart';
import 'package:flutter_manager/widget/env_badge.dart';
import 'package:jtech_base/jtech_base.dart';
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
  final ReorderCallback onReorder;

  // 确认删除回调
  final ProjectConfirmDismissCallback? confirmDismiss;

  // 内间距
  final EdgeInsetsGeometry padding;

  const ProjectGridView({
    super.key,
    required this.projects,
    required this.onReorder,
    this.onEdit,
    this.onPinned,
    this.onDelete,
    this.onDetail,
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
      onReorder: onReorder,
      itemCount: projects.length,
      gridDelegate: _gridDelegate,
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
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    var bodyStyle = Theme.of(context).textTheme.bodySmall;
    final color = bodyStyle?.color?.withValues(alpha: 0.4);
    bodyStyle = bodyStyle?.copyWith(color: color, fontSize: 10);
    final titleConstraints = BoxConstraints.loose(const Size.fromWidth(105));
    final borderRadius = BorderRadius.circular(8);
    const imageSize = Size.square(45);
    return InkWell(
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: item.color.withValues(alpha: 0.2),
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          spacing: 14,
          children: [
            item.logo.isNotEmpty
                ? ClipRRect(
                    borderRadius: borderRadius,
                    child: CustomImage.file(item.logo, size: imageSize),
                  )
                : SizedBox.fromSize(size: imageSize),
            Expanded(
              child: Column(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(spacing: 8, children: [
                    ConstrainedBox(
                      constraints: titleConstraints,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        style: titleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildEnvironmentBadge(item),
                  ]),
                  Text(
                    item.path,
                    maxLines: 2,
                    style: bodyStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Transform.rotate(
              angle: item.pinned ? 45 : 0,
              child: IconButton(
                iconSize: 18,
                icon: const Icon(Icons.push_pin_outlined),
                onPressed: () => onPinned?.call(item),
              ),
            ),
          ],
        ),
      ),
      onTap: () => onDetail?.call(item),
    );
  }

  // 构建项目环境标签
  Widget _buildEnvironmentBadge(Project item) {
    return EnvBadge(env: database.getEnvById(item.envId));
  }
}
