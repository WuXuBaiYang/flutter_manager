import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 打包页
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackagePage extends BasePage {
  const PackagePage({super.key, super.primary = false});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(create: (_) => PackagePageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打包'),
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
* 打包页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackagePageProvider extends BaseProvider {}
