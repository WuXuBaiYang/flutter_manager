import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/*
* 项目平台信息项组件
* @author wuxubaiyang
* @Time 2023/12/1 17:30
*/
class ProjectPlatformItem extends StatelessWidget {
  // 主轴方向的单元格大小
  final double? mainAxisExtent;

  // 主轴方向的单元格数量
  final int crossAxisCellCount;

  // 子元素
  final Widget content;

  // 标题
  final String? title;

  // 动作按钮集合
  final List<Widget>? actions;

  // 点击事件
  final GestureTapCallback? onTap;

  const ProjectPlatformItem({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisExtent,
    required this.content,
    this.title,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGridTile.extent(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: mainAxisExtent!,
      child: _buildPlatformItem(context),
    );
  }

  // 构建平台信息项
  Widget _buildPlatformItem(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Container(
          constraints: const BoxConstraints.expand(),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (title != null)
                  Text(title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                ...actions ?? []
              ]),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}
