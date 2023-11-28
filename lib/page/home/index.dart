import 'package:flutter_manager/common/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/page/knowledge/index.dart';
import 'package:flutter_manager/page/package/index.dart';
import 'package:flutter_manager/page/project/index.dart';
import 'package:flutter_manager/page/settings/index.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/tool/tool.dart';
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
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final provider = context.watch<HomePageProvider>()
      ..registerSettingsJumper(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: provider.navigationIndex,
            trailing: _buildNavigationRailTrailing(),
            destinations: provider.navigationRailList,
            onDestinationSelected: provider.setNavigationIndex,
          ),
          const VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: provider.navigationIndex,
              children: provider.navigationRailPageList,
            ),
          ),
        ],
      ),
    );
  }

  // 构建导航侧栏尾部
  Widget _buildNavigationRailTrailing() {
    return Expanded(
      child: Column(
        children: [
          const Spacer(),
          FutureProvider<String>(
            initialData: '',
            create: (_) => Tool.version,
            builder: (context, _) {
              return TextButton(
                child: Text('v${context.watch<String>()}'),
                onPressed: () {
                  /// TODO: 2021/8/31 14:25 版本更新检查
                },
              );
            },
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/*
* 首页状态管理
* @author wuxubaiyang
* @Time 2023/11/21 14:02
*/
class HomePageProvider extends ChangeNotifier {
  // 导航下标管理
  int _navigationIndex = 0;

  // 导航列表
  final navigationRailList = [
    const NavigationRailDestination(
      padding: EdgeInsets.only(top: 8),
      icon: Icon(Icons.home_rounded),
      label: Text('项目'),
    ),
    const NavigationRailDestination(
      padding: EdgeInsets.only(top: 8),
      icon: Icon(Icons.build),
      label: Text('打包'),
    ),
    const NavigationRailDestination(
      padding: EdgeInsets.only(top: 8),
      icon: Icon(Icons.document_scanner),
      label: Text('知识库'),
    ),
    const NavigationRailDestination(
      padding: EdgeInsets.only(top: 8),
      icon: Icon(Icons.settings),
      label: Text('设置'),
    ),
  ];

  // 导航页面列表
  final navigationRailPageList = [
    const ProjectPage(),
    const PackagePage(),
    const KnowledgePage(),
    const SettingsPage(),
  ];

  // 获取导航下标
  int get navigationIndex => _navigationIndex;

  // 设置导航下标
  setNavigationIndex(int index) {
    if (index < 0 || index >= navigationRailList.length) return;
    _navigationIndex = index;
    notifyListeners();
  }

  // 注册监听回调
  VoidCallback? _settingListener;

  // 注册设置跳转监听
  void registerSettingsJumper(BuildContext context) {
    if (_settingListener != null) return;
    context.read<SettingProvider>().addListener(_settingListener ??= () {
          setNavigationIndex(navigationRailPageList.length - 1);
        });
  }
}
