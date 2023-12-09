import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

/*
* 项目平台信息页面基类
* @author wuxubaiyang
* @Time 2023/12/1 9:41
*/
abstract class ProjectPlatformPage<T extends ProjectPlatformProvider,
    S extends Record> extends BasePage {
  const ProjectPlatformPage({super.key, super.primary = false});

  @override
  Widget buildWidget(BuildContext context) {
    final platform = context.read<T>().platform;
    return Selector<PlatformProvider, PlatformInfoTuple<S>?>(
      selector: (_, provider) => provider.getPlatformTuple<S>(platform),
      builder: (_, platformTuple, __) {
        return EmptyBoxView(
          hint: '无平台信息',
          isEmpty: platformTuple == null,
          icon: IconButton.outlined(
            iconSize: 45,
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.read<T>().createPlatform().loading(context),
          ),
          child: _buildPlatformWidget(context, platformTuple),
        );
      },
    );
  }

  // 构建平台信息
  Widget _buildPlatformWidget(
      BuildContext context, PlatformInfoTuple<S>? platformInfo) {
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
      BuildContext context, PlatformInfoTuple<S>? platformInfo);
}

/*
* 项目平台信息provider
* @author wuxubaiyang
* @Time 2023/11/30 18:48
*/
abstract class ProjectPlatformProvider extends BaseProvider {
  // 平台类型
  final PlatformType platform;

  ProjectPlatformProvider(super.context, this.platform);

  // 创建平台信息
  Future<void> createPlatform() =>
      context.read<PlatformProvider>().createPlatform(project, platform);

  // 获取项目信息
  Project? get project => context.read<ProjectDetailPageProvider>().project;
}
