import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 打包页
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class HomePackageView extends ProviderView<HomePackageProvider> {
  HomePackageView({super.key});

  @override
  HomePackageProvider? createProvider(BuildContext context) =>
      HomePackageProvider(context);

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

class HomePackageProvider extends BaseProvider {
  HomePackageProvider(super.context);
}
