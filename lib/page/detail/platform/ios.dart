import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情-ios平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPage extends BasePage {
  const ProjectPlatformIosPage({super.key});

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(create: (_) => ProjectPlatformIosPageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目详情-ios平台信息页'),
      ),
    );
  }
}

/*
* 项目详情-ios平台信息页-状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPageProvider extends ChangeNotifier {}
