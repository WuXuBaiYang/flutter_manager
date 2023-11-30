import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目详情页
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPage extends BasePage {
  const ProjectDetailPage({super.key});

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(create: (_) => ProjectDetailPageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目详情页'),
      ),
    );
  }
}

/*
* 项目详情页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPageProvider extends ChangeNotifier {}
