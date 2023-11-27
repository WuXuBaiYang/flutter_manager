import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 项目页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class ProjectPage extends BasePage {
  const ProjectPage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

/*
* 项目列表页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class ProjectProvider extends ChangeNotifier {}
