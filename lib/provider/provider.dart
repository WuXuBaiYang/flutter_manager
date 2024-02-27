import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'environment.dart';
import 'project.dart';
import 'setting.dart';
import 'theme.dart';
import 'window.dart';

/*
* 全局provider管理
* @author wuxubaiyang
* @Time 2024/2/27 10:35
*/
class GlobeProvider {
  // 加载全局provider
  static List<SingleChildWidget> providers(BuildContext context) => [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => WindowProvider(context),
        ),
        ChangeNotifierProvider<EnvironmentProvider>(
          create: (_) => EnvironmentProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingProvider(context),
        ),
      ];
}

// 扩展context
extension GlobeProviderExtension on BuildContext {
  // 获取主题provider
  ThemeProvider get theme =>
      Provider.of<ThemeProvider>(this, listen: false);

  // 获取窗口provider
  WindowProvider get window =>
      Provider.of<WindowProvider>(this, listen: false);

  // 获取环境provider
  EnvironmentProvider get environment =>
      Provider.of<EnvironmentProvider>(this, listen: false);

  // 获取项目provider
  ProjectProvider get project =>
      Provider.of<ProjectProvider>(this, listen: false);

  // 获取设置provider
  SettingProvider get setting =>
      Provider.of<SettingProvider>(this, listen: false);
}
