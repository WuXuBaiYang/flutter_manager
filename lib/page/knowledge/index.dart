import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 知识库页面
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgePage extends BasePage {
  const KnowledgePage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => KnowledgeProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
      ),
    );
  }
}

/*
* 状态管理
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgeProvider extends ChangeNotifier {}
