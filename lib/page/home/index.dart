import 'package:flutter/material.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/widget/dialog/android_sign_key.dart';
import 'package:flutter_manager/widget/status_bar.dart';
import 'package:jtech_base/jtech_base.dart';

import 'knowledge/index.dart';
import 'package/index.dart';
import 'project/index.dart';
import 'settings/index.dart';

/*
* 首页
* @author wuxubaiyang
* @Time 2023/11/21 13:57
*/
class HomePage extends ProviderPage<HomePageProvider> {
  const HomePage({super.key, required super.context, super.state});

  @override
  HomePageProvider createProvider(BuildContext context, GoRouterState? state) =>
      HomePageProvider(context, state);

  @override
  Widget buildWidget(BuildContext context) {
    final brightness = context.theme.brightness;
    return Scaffold(
      appBar: StatusBar(
        brightness: brightness,
      ),
      body: _buildContent(context),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final children = pageProvider.pages.map((e) {
      return e.child ?? const SizedBox();
    }).toList();
    return Selector<HomePageProvider, int>(
      selector: (_, provider) => provider.currentIndex,
      builder: (_, currentIndex, __) {
        return Row(children: [
          _buildNavigationRail(context, currentIndex),
          const VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: children,
            ),
          ),
        ]);
      },
    );
  }

  // 构建导航栏
  Widget _buildNavigationRail(BuildContext context, int currentIndex) {
    return NavigationRail(
      selectedIndex: currentIndex,
      trailing: _buildNavigationRailTrailing(),
      onDestinationSelected: pageProvider.setCurrentIndex,
      destinations: pageProvider.pages.map((e) {
        return NavigationRailDestination(
          padding: EdgeInsets.only(top: 8),
          icon: e.icon ?? Icon(Icons.error),
          label: Text(e.label),
        );
      }).toList(),
    );
  }

  // 构建导航侧栏尾部
  Widget _buildNavigationRailTrailing() {
    return Expanded(
      child: Column(children: [
        const Spacer(),
        FutureProvider<String>(
          initialData: '',
          create: (_) => Tool.version,
          builder: (context, _) {
            return TextButton(
              child: Text('v${context.watch<String>()}'),
              onPressed: () async {
                showAndroidSignKey(context);

                /// TODO: 2021/8/31 14:25 版本更新检查
              },
            );
          },
        ),
        const SizedBox(height: 14),
      ]),
    );
  }
}

/*
* 首页状态管理
* @author wuxubaiyang
* @Time 2023/11/21 14:02
*/
class HomePageProvider extends PageProvider {
  // 导航分页集合
  late final pages = <OptionItem>[
    OptionItem(
      label: '项目',
      icon: Icon(Icons.home_rounded),
      child: ProjectPage(context: context),
    ),
    OptionItem(
      label: '打包',
      icon: Icon(Icons.build),
      child: PackagePage(context: context),
    ),
    OptionItem(
      label: '知识库',
      icon: Icon(Icons.document_scanner),
      child: KnowledgePage(context: context),
    ),
    OptionItem(
      label: '设置',
      icon: Icon(Icons.settings),
      child: SettingsPage(context: context),
    ),
  ];

  HomePageProvider(super.context, super.state) {
    // 注册设置跳转方法
    context.setting.addListener(() {
      if (context.setting.selectedKey != null) {
        setCurrentIndex(pages.length - 1);
      }
    });
  }

  // 导航下标管理
  int _currentIndex = 0;

  // 获取导航下标
  int get currentIndex => _currentIndex;

  // 判断传入下标是否为当前下标
  bool isCurrentIndex(int index) => _currentIndex == index;

  // 设置导航下标
  void setCurrentIndex(int index) {
    if (index < 0 || index >= pages.length) return;
    _currentIndex = index;
    notifyListeners();
  }
}
