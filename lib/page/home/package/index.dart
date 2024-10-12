import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 打包页
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackagePage extends ProviderPage<PackagePageProvider> {
  PackagePage({super.key, super.state});

  @override
  PackagePageProvider createProvider(
          BuildContext context, GoRouterState? state) =>
      PackagePageProvider(context, state);

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
* 打包页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackagePageProvider extends PageProvider {
  PackagePageProvider(super.context, super.state);
}
