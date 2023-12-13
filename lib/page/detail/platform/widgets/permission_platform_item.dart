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
      title: '权限管理',
      actions: [
        _buildAddPermissionButton(context),
      ],
      mainAxisExtent: mainAxisExtent,
      crossAxisCellCount: crossAxisCellCount,
      content: EmptyBoxView(
        hint: '暂无权限信息',
        isEmpty: permissions.isEmpty,
        child: _buildPermissionList(),
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

  // 构建权限列表
  Widget _buildPermissionList() {
    return const SizedBox();
  }
}
