import 'package:flutter_manager/common/localization/chinese_cupertino_localizations.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:window_manager/window_manager.dart';
import 'generated/l10n.dart';
import 'provider/project.dart';
import 'provider/window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化所有管理方法
  await Future.forEach(
    [router, cache, database],
    (e) => e.initialize(),
  );
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
  List<SingleChildWidget> loadProviders(BuildContext context) => [
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

  @override
  Widget buildWidget(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, provider, child) {
        return MaterialApp(
          title: 'Flutter项目管理',
          theme: provider.themeData,
          themeMode: provider.themeMode,
          darkTheme: provider.darkThemeData,
          navigatorKey: router.navigateKey,
          debugShowCheckedModeBanner: false,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            ChineseCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: router.onGenerateRoute(
            routesMap: RoutePath.routes,
          ),
          home: child,
        );
      },
      child: const HomePage(),
    );
  }
}
