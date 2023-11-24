import 'package:flutter_manager/common/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 首页
* @author wuxubaiyang
* @Time 2023/11/21 13:57
*/
class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final c = context.read<ThemeProvider>().themeMode;
          context.read<ThemeProvider>().changeThemeMode(
              context, c == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*
* 首页状态管理
* @author wuxubaiyang
* @Time 2023/11/21 14:02
*/
class HomeProvider extends ChangeNotifier {}
