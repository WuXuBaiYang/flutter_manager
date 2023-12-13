import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

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
    return Selector<PlatformProvider, PlatformInfoTuple<T>?>(
      selector: (_, provider) => provider.getPlatformTuple<T>(platform),
      builder: (_, platformTuple, __) {
        return EmptyBoxView(
          hint: '无平台信息',
          isEmpty: platformTuple == null,
          child: _buildPlatformWidget(context, platformTuple),
        );
      },
    );
  }

  // 构建平台信息
  Widget _buildPlatformWidget(
      BuildContext context, PlatformInfoTuple<T>? platformInfo) {
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
      BuildContext context, PlatformInfoTuple<T>? platformInfo);
}
