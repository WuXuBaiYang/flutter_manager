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

  // 主轴数量
  final int mainAxisCount;

  // 交叉轴数量
  final int crossAxisCount;

  const ProjectPlatformItem({
    super.key,
    required this.mainAxisCount,
    required this.crossAxisCount,
    required this.child,
  });

  // 获取tile
  QuiltedGridTile get gridTile =>
      QuiltedGridTile(mainAxisCount, crossAxisCount);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Card(child: child),
    );
  }
}
