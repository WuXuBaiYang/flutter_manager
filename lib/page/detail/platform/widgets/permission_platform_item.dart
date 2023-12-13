import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/permission_picker.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'platform_item.dart';
import 'provider.dart';

/*
* 项目平台permission项组件
* @author wuxubaiyang
* @Time 2023/12/8 9:55
*/
class PermissionPlatformItem extends StatelessWidget {
  // 平台
  final PlatformType platform;

  // 权限列表
  final List<PlatformPermissionTuple> permissions;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const PermissionPlatformItem({
    super.key,
    required this.platform,
    required this.permissions,
    this.crossAxisCellCount = 3,
    this.mainAxisExtent = 280,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      title: '权限管理（${permissions.length}）',
      actions: [
        _buildAddPermissionButton(context),
      ],
      mainAxisExtent: mainAxisExtent,
      crossAxisCellCount: crossAxisCellCount,
      content: EmptyBoxView(
        hint: '暂无权限信息',
        isEmpty: permissions.isEmpty,
        child: _buildPermissionList(context),
      ),
    );
  }

  // 构建添加权限按钮
  Widget _buildAddPermissionButton(BuildContext context) {
    final provider = context.read<PlatformProvider>();
    return IconButton(
      iconSize: 20,
      icon: const Icon(Icons.add),
      onPressed: () => PermissionPickerDialog.show(
        context,
        platform: platform,
        permissions: permissions,
      ).then((result) =>
          provider.updatePermission(platform, result).loading(context)),
    );
  }

  // 恢复滚动控制器
  ScrollController _restoreScrollController(BuildContext context) {
    final cacheKey = 'permission_offset_$platform';
    final provider = context.read<PlatformProvider>();
    final offset = provider.restoreCache<double>(cacheKey) ?? 0.0;
    final controller = ScrollController(initialScrollOffset: offset);
    controller.addListener(
        () => provider.cache<dynamic>(cacheKey, controller.offset));
    return controller;
  }

  // 构建权限列表
  Widget _buildPermissionList(BuildContext context) {
    final provider = context.read<PlatformProvider>();
    return DefaultTextStyle(
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      child: ListView.separated(
        itemCount: permissions.length,
        separatorBuilder: (_, i) => const Divider(),
        controller: _restoreScrollController(context),
        itemBuilder: (_, i) {
          final item = permissions[i];
          return Dismissible(
            key: ObjectKey(item),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => provider
                .updatePermission(
                  platform,
                  permissions.where((e) => e != item).toList(),
                )
                .loading(context),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 14),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildItem(context, item),
          );
        },
      ),
    );
  }

  // 构建默认权限列表项
  Widget _buildItem(BuildContext context, PlatformPermissionTuple item) {
    final textStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.name, maxLines: 1),
      subtitle: Text(item.desc, style: textStyle),
    );
  }
}
