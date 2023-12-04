import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

/*
* 平台排序列表
* @author wuxubaiyang
* @Time 2023/12/1 10:32
*/
class PlatformSortList extends StatelessWidget {
  // 项目id
  final Id? projectId;

  // 约束
  final BoxConstraints constraints;

  const PlatformSortList({
    super.key,
    this.projectId,
    this.constraints = const BoxConstraints.tightFor(height: 55),
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: _buildPlatformList(context),
    );
  }

  // 构建平台列表
  Widget _buildPlatformList(BuildContext context) {
    return Selector<ProjectProvider, List<PlatformType>>(
      selector: (_, provider) => provider.platformSort,
      builder: (_, platformSort, __) {
        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          scrollDirection: Axis.horizontal,
          itemCount: platformSort.length,
          onReorder: (oldIndex, newIndex) {
            final platforms = [...platformSort].swap(oldIndex, newIndex);
            context.read<ProjectProvider>().updatePlatformSort(platforms);
          },
          proxyDecorator: (_, index, ___) {
            final item = platformSort[index];
            return Material(
              color: Colors.transparent,
              child: _buildPlatformListItem(context, item),
            );
          },
          itemBuilder: (_, i) {
            final item = platformSort[i];
            return ReorderableDragStartListener(
              index: i,
              key: ValueKey(item.index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPlatformListItem(context, item),
              ),
            );
          },
        );
      },
    );
  }

  // 构建平台列表项
  Widget _buildPlatformListItem(BuildContext context, PlatformType platform) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return ActionChip(
      onPressed: () {},
      label: Text(platform.name, style: textStyle),
      avatar: Icon(Icons.drag_handle, color: textStyle?.color),
    );
  }
}
