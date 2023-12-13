import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/status_bar.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 页面基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class BasePage extends StatelessWidget {
  // 是否为主页面
  final bool primary;

  const BasePage({
    super.key,
    this.primary = true,
  });

  List<SingleChildWidget> loadProviders(BuildContext context) => [];

  @override
  Widget build(BuildContext context) {
    final providers = loadProviders(context);
    if (providers.isEmpty) return _buildContent(context);
    return MultiProvider(
      providers: providers,
      builder: (context, _) {
        return _buildContent(context);
      },
    );
  }

  Widget buildWidget(BuildContext context);

  // 构建内容主体
  Widget _buildContent(BuildContext context) {
    final brightness = context.watch<ThemeProvider>().brightness;
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (primary) StatusBar(brightness: brightness),
          Expanded(child: buildWidget(context)),
        ],
      ),
    );
  }
}
