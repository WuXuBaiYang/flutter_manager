import 'package:flutter_manager/common/localization/chinese_cupertino_localizations.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'generated/l10n.dart';
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
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
      ),
      ChangeNotifierProvider<EnvironmentProvider>(
        create: (_) => EnvironmentProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => WindowProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Flutter项目管理',
      themeMode: provider.themeMode,
      navigatorKey: router.navigateKey,
      debugShowCheckedModeBanner: false,
      darkTheme: provider.darkThemeData,
      theme: provider.getThemeData(context),
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
      home: const HomePage(),
    );
  }
}
