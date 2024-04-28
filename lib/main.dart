import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_manager/common/localization/chinese_cupertino_localizations.dart';
import 'package:flutter_manager/common/route.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/provider/provider.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:window_manager/window_manager.dart';

import 'generated/l10n.dart';
import 'tool/cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化工具方法
  await localCache.initialize();
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
  List<SingleChildWidget> loadProviders(BuildContext context) =>
      GlobeProvider.providers(context);

  @override
  Widget buildWidget(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, provider, child) {
        return MaterialApp.router(
          title: 'Flutter项目管理',
          theme: provider.themeData,
          themeMode: provider.themeMode,
          routerConfig: RoutePath.routes,
          darkTheme: provider.darkThemeData,
          debugShowCheckedModeBanner: false,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            ChineseCupertinoLocalizations.delegate,
          ],
        );
      },
      child: const HomePage(),
    );
  }
}
