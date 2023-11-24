import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 打包页
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackagePage extends BasePage {
  const PackagePage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => PackageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打包页'),
      ),
    );
  }
}

/*
* 打包页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:26
*/
class PackageProvider extends ChangeNotifier {}
