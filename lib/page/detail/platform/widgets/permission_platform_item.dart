import 'package:flutter/material.dart';
import 'package:flutter_manager/model/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'platform_item.dart';

/*
* 项目平台permission项组件
* @author wuxubaiyang
* @Time 2023/12/8 9:55
*/
class PermissionPlatformItem extends StatelessWidget {
  // 平台
  final PlatformType platform;

  // 项目信息
  final Project? project;

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
    this.project,
    this.crossAxisCellCount = 3,
    this.mainAxisExtent = 280,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      title: '权限管理',
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: mainAxisExtent,
      content: SizedBox(),
    );
  }
}
