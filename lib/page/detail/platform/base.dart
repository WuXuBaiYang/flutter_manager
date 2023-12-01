import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'platform_item.dart';

/*
* 项目平台信息页面基类
* @author wuxubaiyang
* @Time 2023/12/1 9:41
*/
abstract class ProjectPlatformPage<T extends ProjectPlatformProvider>
    extends BasePage {
  const ProjectPlatformPage({
    super.key,
    super.primary = false,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final hasPlatform = context.watch<T>().hasPlatform;
    return EmptyBoxView(
      hint: '无平台信息',
      isEmpty: !hasPlatform,
      icon: IconButton.outlined(
        iconSize: 45,
        icon: const Icon(Icons.add),
        onPressed: () => Loading.show(context,
            loadFuture: context.read<T>().createPlatform(context)),
      ),
      child: _buildPlatformWidget(context),
    );
  }

  // 构建平台信息
  Widget _buildPlatformWidget(BuildContext context) {
    final children = buildPlatformItems(context);
    return EmptyBoxView(
      hint: '暂无方法',
      isEmpty: children.isEmpty,
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: children,
      ),
    );
  }

  // 获取平台构造项
  List<ProjectPlatformItem> buildPlatformItems(BuildContext context);
}

/*
* 项目平台信息provider
* @author wuxubaiyang
* @Time 2023/11/30 18:48
*/
abstract class ProjectPlatformProvider extends BaseProvider {
  // 平台类型
  final PlatformPath platform;

  // 缓存是否存在平台信息
  bool _hasPlatform = false;

  // 是否存在平台信息
  bool get hasPlatform => _hasPlatform;

  ProjectPlatformProvider(BuildContext context, this.platform) {
    final project = getProjectInfo(context);
    if (project == null) return;
    // 初始化是否存在平台信息
    _hasPlatform = ProjectTool.hasPlatform(platform, project.path);
  }

  // 创建平台信息
  Future<bool> createPlatform(BuildContext context) async {
    final project = getProjectInfo(context);
    if (project == null) return false;
    _hasPlatform = await ProjectTool.createPlatform(project, platform);
    notifyListeners();
    return _hasPlatform;
  }

  // 获取项目信息
  Project? getProjectInfo(BuildContext context) =>
      context.read<ProjectDetailPageProvider>().project;
}