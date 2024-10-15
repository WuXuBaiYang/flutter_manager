import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/generated/l10n.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/app_bar.dart';
import 'package:flutter_manager/widget/dialog/environment/import_local.dart';
import 'package:flutter_manager/widget/dialog/project_import.dart';
import 'package:flutter_manager/widget/drop_file.dart';
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
class HomePage extends ProviderPage<HomeProvider> {
  HomePage({super.key, super.state});

  @override
  HomeProvider createPageProvider(BuildContext context, GoRouterState? state) =>
      HomeProvider(context, state);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(S.current.appName),
      ),
      body: DropFileView(
        hint: '可导入项目/环境',
        onDoneValidator: provider.dropDone,
        child: _buildContent(context),
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final children = provider.pages.map((e) {
      return e.child ?? const SizedBox();
    }).toList();
    return Selector<HomeProvider, int>(
      selector: (_, provider) => provider.currentIndex,
      builder: (_, currentIndex, __) {
        return Row(children: [
          _buildNavigation(context, currentIndex),
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
  Widget _buildNavigation(BuildContext context, int currentIndex) {
    return NavigationRail(
      selectedIndex: currentIndex,
      trailing: _buildNavigationTrailing(context),
      onDestinationSelected: provider.setCurrentIndex,
      destinations: provider.pages.map((e) {
        return NavigationRailDestination(
          padding: EdgeInsets.only(top: 8),
          icon: e.icon ?? Icon(Icons.error),
          label: Text(e.label),
        );
      }).toList(),
    );
  }

  // 构建导航侧栏尾部
  Widget _buildNavigationTrailing(BuildContext context) {
    return Expanded(
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FutureBuilder<String>(
          future: Tool.version,
          builder: (_, snap) {
            return TextButton(
              onPressed: provider.checkAppVersion,
              child: Text('v${snap.data}'),
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
class HomeProvider extends PageProvider {
  // 导航分页集合
  late final pages = <OptionItem>[
    OptionItem(
      label: '项目',
      icon: Icon(Icons.home_rounded),
      child: HomeProjectView(),
    ),
    OptionItem(
      label: '打包',
      icon: Icon(Icons.build),
      child: HomePackageView(),
    ),
    OptionItem(
      label: '知识库',
      icon: Icon(Icons.document_scanner),
      child: HomeKnowledgeView(),
    ),
    OptionItem(
      label: '设置',
      icon: Icon(Icons.settings),
      child: HomeSettingsView(),
    ),
  ];

  HomeProvider(super.context, super.state) {
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

  // 文件拖拽完成
  Future<String?> dropDone(List<String> paths) async {
    for (var e in paths) {
      // 判断是否为环境信息
      if (EnvironmentTool.isAvailable(e)) {
        final env = Environment.createImport(e);
        await showImportEnvLocal(context, env: env);
      } else {
        // 判断是否为项目信息(如果没有环境则无法导入项目)
        final project = await ProjectTool.getProjectInfo(e);
        if (project == null || !context.mounted) continue;
        if (!context.env.hasEnvironment) return '请先添加环境信息';
        await showProjectImport(context, project: project);
      }
    }
    return null;
  }

  // 检查版本更新
  void checkAppVersion() {
    /// TODO 检查版本更新
  }

  // 设置导航下标
  void setCurrentIndex(int index) {
    if (index < 0 || index >= pages.length) return;
    _currentIndex = index;
    notifyListeners();
  }
}
