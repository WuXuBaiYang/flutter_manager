import 'package:flutter/material.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/status_bar.dart';
import 'package:provider/provider.dart';

/*
* 页面基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class ProviderPage extends ProviderView {
  // 是否为主页面
  final bool primary;

  const ProviderPage({
    super.key,
    this.primary = true,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final brightness = context.watch<ThemeProvider>().brightness;
    return Material(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (primary) StatusBar(brightness: brightness),
        Expanded(child: buildPage(context)),
      ]),
    );
  }

  // 构建页面内容
  Widget buildPage(BuildContext context);
}
