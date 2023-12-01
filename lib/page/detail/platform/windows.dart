import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-windows平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsPage extends ProjectPlatformPage {
  const ProjectPlatformWindowsPage({super.key});

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(
            create: (_) => ProjectPlatformWindowsPageProvider()),
      ];
}

/*
* 项目详情-windows平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsPageProvider extends ProjectPlatformProvider {}
