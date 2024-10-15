import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 首页-知识库分页
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class HomeKnowledgeView extends ProviderView<HomeKnowledgeProvider> {
  HomeKnowledgeView({super.key});

  @override
  HomeKnowledgeProvider? createProvider(BuildContext context) =>
      HomeKnowledgeProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: const EmptyBoxView(
        isEmpty: true,
        hint: '功能施工中',
        iconData: Icons.build,
        child: SizedBox(),
      ),
    );
  }
}

class HomeKnowledgeProvider extends BaseProvider {
  HomeKnowledgeProvider(super.context);
}
