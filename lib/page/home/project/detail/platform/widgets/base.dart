import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jtech_base/jtech_base.dart';

import 'provider.dart';

/*
* 项目平台信息页面基类
* @author wuxubaiyang
* @Time 2023/12/1 9:41
*/
abstract class ProjectPlatformView<T extends Record> extends StatelessWidget {
  // 当前平台
  final PlatformType platform;

  const ProjectPlatformView({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    return Selector<PlatformProvider, PlatformInfo<T>?>(
      selector: (_, provider) => provider.getPlatform<T>(platform),
      builder: (_, platform, _) {
        return EmptyBoxView(
          hint: '无平台信息',
          isEmpty: platform == null,
          builder: (_, _) {
            if (platform == null) return const SizedBox();
            return _buildPlatformWidget(context, platform);
          },
        );
      },
    );
  }

  // 构建平台信息
  Widget _buildPlatformWidget(
      BuildContext context, PlatformInfo<T> platformInfo) {
    final children = buildPlatformItems(context, platformInfo);
    return EmptyBoxView(
      hint: '暂无方法',
      isEmpty: children.isEmpty,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: StaggeredGrid.extent(
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          maxCrossAxisExtent: 100,
          children: children,
        ),
      ),
    );
  }

  // 获取平台构造项
  List<Widget> buildPlatformItems(
      BuildContext context, PlatformInfo<T> platformInfo);
}
