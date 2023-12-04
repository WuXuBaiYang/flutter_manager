import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/image.dart';
import 'project/platform/platform.dart';

/*
* 项目图标网格组件
* @author wuxubaiyang
* @Time 2023/12/4 16:27
*/
class ProjectLogoGrid extends StatelessWidget {
  // 最大尺寸
  final Size maxSize;

  // 图标列表
  final List<PlatformLogoTuple> logoList;

  // 点击事件
  final ValueChanged<PlatformLogoTuple>? onTap;

  const ProjectLogoGrid({
    super.key,
    required this.logoList,
    this.onTap,
    this.maxSize = const Size.square(55),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: List.generate(logoList.length, (i) {
        final item = logoList[i];
        return _buildLogoItem(item);
      }),
    );
  }

  // 构建图标项
  Widget _buildLogoItem(PlatformLogoTuple item) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap != null ? () => onTap?.call(item) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.loose(maxSize),
              child: ImageView.file(File(item.path)),
            ),
            const SizedBox(height: 4),
            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
