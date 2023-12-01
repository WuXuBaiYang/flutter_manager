import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPage
    extends ProjectPlatformPage<ProjectPlatformAndroidPageProvider> {
  const ProjectPlatformAndroidPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformAndroidPageProvider(context, PlatformPath.android),
        ),
      ];
}

/*
* 项目详情-android平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPageProvider extends ProjectPlatformProvider {
  ProjectPlatformAndroidPageProvider(super.context, super.platform);
}
