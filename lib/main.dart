import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:window_manager/window_manager.dart';
import 'common/route.dart';
import 'generated/l10n.dart';
import 'provider/config.dart';
import 'provider/environment.dart';
import 'provider/project.dart';
import 'provider/setting.dart';
import 'provider/window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化工具方法
  await localCache.initialize();
  await database.initialize(Common.databaseName);
  // 初始化窗口管理
  const windowSize = Size(800, 600);
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    size: windowSize,
    skipTaskbar: false,
    minimumSize: windowSize,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends ProviderView {
  const MyApp({super.key});

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(context)),
        ChangeNotifierProvider(create: (context) => WindowProvider(context)),
        ChangeNotifierProvider<EnvironmentProvider>(
            create: (context) => EnvironmentProvider(context)),
        ChangeNotifierProvider(create: (context) => ProjectProvider(context)),
        ChangeNotifierProvider(create: (context) => SettingProvider(context)),
        ChangeNotifierProvider<ConfigProvider>(
            create: (context) => ConfigProvider(context)),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) {
        return MaterialApp.router(
          theme: theme.themeData,
          title: S.current.appName,
          themeMode: theme.themeMode,
          darkTheme: theme.darkThemeData,
          debugShowCheckedModeBanner: false,
          routerConfig: router.createRouter(
            initialLocation: router.homePath,
          ),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

// 扩展context
extension GlobeProviderExtension on BuildContext {
  // 获取主题provider
  ThemeProvider get theme => Provider.of<ThemeProvider>(this, listen: false);

  // 获取窗口provider
  WindowProvider get window => Provider.of<WindowProvider>(this, listen: false);

  // 获取环境provider
  EnvironmentProvider get environment =>
      Provider.of<EnvironmentProvider>(this, listen: false);

  // 获取项目provider
  ProjectProvider get project =>
      Provider.of<ProjectProvider>(this, listen: false);

  // 获取设置provider
  SettingProvider get setting =>
      Provider.of<SettingProvider>(this, listen: false);

  // 获取配置provider
  ConfigProvider get config => Provider.of<ConfigProvider>(this, listen: false);
}
