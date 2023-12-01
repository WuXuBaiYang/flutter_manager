import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-linux平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformLinuxPage extends ProjectPlatformPage {
  const ProjectPlatformLinuxPage(
      {super.key, super.platformPath = PlatformPath.linux});

  @override
  PlatformPath get platformPath => PlatformPath.linux;

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
            create: (_) => ProjectPlatformLinuxPageProvider()),
      ];
}

/*
* 项目详情-linux平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformLinuxPageProvider extends ProjectPlatformProvider {}
