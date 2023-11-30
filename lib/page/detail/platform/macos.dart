import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-macos平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPage extends BasePage {
  const ProjectPlatformMacosPage({super.key});

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(
            create: (_) => ProjectPlatformMacosPageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目详情-macos平台信息页'),
      ),
    );
  }
}

/*
* 项目详情-macos平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPageProvider extends ChangeNotifier {}
