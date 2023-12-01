import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 知识库页面
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgePage extends BasePage {
  const KnowledgePage({super.key, super.primary = false});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(create: (_) => KnowledgePageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
      ),
      body: const EmptyBoxView(
        isEmpty: true,
        hint: '功能施工中',
        iconData: Icons.build,
        child: SizedBox(),
      ),
    );
  }
}

/*
* 状态管理
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgePageProvider extends BaseProvider {}
