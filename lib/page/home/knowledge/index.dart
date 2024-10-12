import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 知识库页面
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgePage extends ProviderPage<KnowledgePageProvider> {
  KnowledgePage({super.key, super.state});

  @override
  KnowledgePageProvider createProvider(
          BuildContext context, GoRouterState? state) =>
      KnowledgePageProvider(context, state);

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

/*
* 状态管理
* @author wuxubaiyang
* @Time 2023/11/26 18:21
*/
class KnowledgePageProvider extends PageProvider {
  KnowledgePageProvider(super.context, super.state);
}
