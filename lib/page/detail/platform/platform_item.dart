import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/*
* 项目平台信息项组件
* @author wuxubaiyang
* @Time 2023/12/1 17:30
*/
class ProjectPlatformItem extends StatelessWidget {
  // 主轴方向的单元格数量
  final int crossAxisCellCount;

  // 交叉轴方向的单元格数量
  final num? mainAxisCellCount;

  // 主轴方向的单元格大小
  final double? mainAxisExtent;

  // 子元素
  final List<Widget> children;

  // 点击事件
  final GestureTapCallback? onTap;

  // 标题
  final String? title;

  const ProjectPlatformItem.count({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.children,
    this.title,
    this.onTap,
  }) : mainAxisExtent = null;

  const ProjectPlatformItem.extent({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisExtent,
    required this.children,
    this.title,
    this.onTap,
  }) : mainAxisCellCount = null;

  const ProjectPlatformItem.fit({
    super.key,
    required this.crossAxisCellCount,
    required this.children,
    this.title,
    this.onTap,
  })  : mainAxisCellCount = null,
        mainAxisExtent = null;

  @override
  Widget build(BuildContext context) {
    if (mainAxisCellCount != null) {
      return StaggeredGridTile.count(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisCellCount: mainAxisCellCount!,
        child: _buildPlatformItem(context),
      );
    }
    if (mainAxisExtent != null) {
      return StaggeredGridTile.extent(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisExtent: mainAxisExtent!,
        child: _buildPlatformItem(context),
      );
    }
    return StaggeredGridTile.fit(
      crossAxisCellCount: crossAxisCellCount,
      child: _buildPlatformItem(context),
    );
  }

  // 构建平台信息项
  Widget _buildPlatformItem(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 8, horizontal: 14);
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title?.isNotEmpty ?? false)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
