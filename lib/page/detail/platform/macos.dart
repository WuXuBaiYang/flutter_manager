import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'platform_item.dart';

/*
* 项目详情-macos平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPage
    extends ProjectPlatformPage<ProjectPlatformMacosPageProvider> {
  const ProjectPlatformMacosPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformMacosPageProvider(context, PlatformType.macos),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context) {
    return [];
  }
}

/*
* 项目详情-macos平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPageProvider extends ProjectPlatformProvider {
  ProjectPlatformMacosPageProvider(super.context, super.platform);
}
