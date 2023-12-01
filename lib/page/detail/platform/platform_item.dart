import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/*
* 项目平台信息项组件
* @author wuxubaiyang
* @Time 2023/12/1 17:30
*/
class ProjectPlatformItem extends StatelessWidget {
  // 子元素
  final Widget child;

  // 主轴方向的单元格数量
  final int crossAxisCellCount;

  // 交叉轴方向的单元格数量
  final num? mainAxisCellCount;

  // 主轴方向的单元格大小
  final double? mainAxisExtent;

  const ProjectPlatformItem.count({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.child,
  }) : mainAxisExtent = null;

  const ProjectPlatformItem.extent({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisExtent,
    required this.child,
  }) : mainAxisCellCount = null;

  const ProjectPlatformItem.fit({
    super.key,
    required this.crossAxisCellCount,
    required this.child,
  })  : mainAxisCellCount = null,
        mainAxisExtent = null;

  @override
  Widget build(BuildContext context) {
    if (mainAxisCellCount != null) {
      return StaggeredGridTile.count(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisCellCount: mainAxisCellCount!,
        child: _buildPlatformItem(),
      );
    }
    if (mainAxisExtent != null) {
      return StaggeredGridTile.extent(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisExtent: mainAxisExtent!,
        child: _buildPlatformItem(),
      );
    }
    return StaggeredGridTile.fit(
      crossAxisCellCount: crossAxisCellCount,
      child: _buildPlatformItem(),
    );
  }

  // 构建平台信息项
  Widget _buildPlatformItem() {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}
