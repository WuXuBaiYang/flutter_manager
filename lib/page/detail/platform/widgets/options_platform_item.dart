import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'platform_item.dart';

/*
* 项目平台操作项组件
* @author wuxubaiyang
* @Time 2023/12/8 9:55
*/
class OptionsPlatformItem extends StatelessWidget {
  // 平台
  final PlatformType platform;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const OptionsPlatformItem({
    super.key,
    required this.platform,
    this.crossAxisCellCount = 2,
    this.mainAxisExtent = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: mainAxisExtent,
      content: _buildOptions(context),
    );
  }

  // 构建操作项
  Widget _buildOptions(BuildContext context) {
    final provider = context.read<PlatformProvider>();
    return Row(children: [
      IconButton.filledTonal(
        tooltip: '删除平台',
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () => provider.removePlatform(platform).loading(context),
      ),
    ]);
  }
}
