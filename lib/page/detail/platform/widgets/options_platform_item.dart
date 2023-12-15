import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/alert_message.dart';
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

  // 添加操作集合
  final List<Widget>? actions;

  const OptionsPlatformItem({
    super.key,
    required this.platform,
    this.crossAxisCellCount = 2,
    this.mainAxisExtent = 100,
    this.actions,
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
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      ...actions ?? [],
      IconButton.filled(
        isSelected: false,
        tooltip: '刷新平台信息',
        icon: const Icon(Icons.refresh_rounded),
        onPressed: () => provider
            .updatePlatformInfo(platform)
            .loading(context)
            .then((_) => provider.clearCacheByPlatform(platform)),
      ),
      IconButton.filled(
        tooltip: '删除平台',
        isSelected: false,
        color: Colors.redAccent.withOpacity(0.6),
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () => showAlertMessage(
          context,
          title: '删除平台',
          content: '是否删除当前平台？',
        ).then((result) {
          if (result != true) return;
          provider.removePlatform(platform).loading(context);
        }),
      ),
    ]);
  }
}
