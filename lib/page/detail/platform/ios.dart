import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'platform_item.dart';

/*
* 项目详情-ios平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPage
    extends ProjectPlatformPage<ProjectPlatformIosPageProvider> {
  const ProjectPlatformIosPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformIosPageProvider(context, PlatformPath.ios),
        ),
      ];

  @override
  List<ProjectPlatformItem> buildPlatformItems(BuildContext context) {
    return [];
  }
}

/*
* 项目详情-ios平台信息页-状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPageProvider extends ProjectPlatformProvider {
  ProjectPlatformIosPageProvider(super.context, super.platform);
}
