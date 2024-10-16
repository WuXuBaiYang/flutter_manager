import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/project/label.dart';
import 'package:flutter_manager/widget/dialog/project/logo.dart';
import 'package:jtech_base/jtech_base.dart';
import 'platform/widgets/provider.dart';

/*
* 项目详情页TabBar组件
* @author wuxubaiyang
* @Time 2023/12/13 16:22
*/
class ProjectDetailTabBar extends StatelessWidget {
  // 平台集合
  final List<PlatformType> platforms;

  const ProjectDetailTabBar({super.key, required this.platforms});

  @override
  Widget build(BuildContext context) {
    final tabs = platforms.map((e) => Tab(text: e.name)).toList();
    return Row(children: [
      TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        splashBorderRadius: BorderRadius.circular(4),
        tabs: [
          ...tabs,
          if (tabs.isEmpty) const Tab(text: '暂无平台'),
        ],
      ),
      Expanded(child: _buildActions(context, platforms)),
      const SizedBox(width: 8),
    ]);
  }

  // 构建平台聚合操作项
  Widget _buildActions(BuildContext context, List<PlatformType> platforms) {
    final provider = context.read<PlatformProvider>();
    final createPlatforms =
        PlatformType.values.where((e) => !platforms.contains(e)).toList();
    return Row(children: [
      if (createPlatforms.isNotEmpty)
        PopupMenuButton(
          iconSize: 20,
          tooltip: '创建平台',
          icon: const Icon(Icons.add),
          onSelected: (v) => provider.createPlatform(v).loading(context),
          itemBuilder: (_) => createPlatforms
              .map((e) => PopupMenuItem(
                    value: e,
                    child: Text(e.name),
                  ))
              .toList(),
        ),
      const Spacer(),
      Tooltip(
        message: '替换项目名',
        child: TextButton.icon(
          label: const Text('名称'),
          icon: const Icon(Icons.edit_attributes_rounded, size: 18),
          onPressed: () async {
            final result = await showProjectLabel(
              context,
              labelMap: provider.labelMap,
            );
            if (result == null || !context.mounted) return;
            provider.updateLabels(result).loading(context, dismissible: false);
          },
        ),
      ),
      Tooltip(
        message: '替换图标',
        child: TextButton.icon(
          label: const Text('图标'),
          onPressed: () async {
            final result = await showProjectLogo(context,
                platformLogoMap: provider.logoMap);
            if (result == null || !context.mounted) return;
            final controller = StreamController<double>();
            provider
                .updateLogos(result, controller: controller)
                .loading(context, dismissible: false);
          },
          icon: const Icon(Icons.imagesearch_roller_rounded, size: 18),
        ),
      ),
    ]);
  }
}
