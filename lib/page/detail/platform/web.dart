import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-web平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformWebPage
    extends ProjectPlatformPage<ProjectPlatformWebPageProvider> {
  const ProjectPlatformWebPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformWebPageProvider(context, PlatformPath.web),
        ),
      ];
}

/*
* 项目详情-web平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformWebPageProvider extends ProjectPlatformProvider {
  ProjectPlatformWebPageProvider(super.context, super.platform);
}
