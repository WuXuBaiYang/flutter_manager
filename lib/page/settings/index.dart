import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/dialog/environment_import.dart';
import 'package:flutter_manager/widget/dialog/environment_import_remote.dart';
import 'package:flutter_manager/widget/drop_file.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:open_dir/open_dir.dart';

import 'settings.dart';

/*
* 设置页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class SettingsPage extends ProviderPage<SettingsPageProvider> {
  const SettingsPage({super.key, super.state});

  @override
  SettingsPageProvider createProvider(
          BuildContext context, GoRouterState? state) =>
      SettingsPageProvider(context, state);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _buildDropArea(context),
    );
  }

  // 构建拖拽内容区域
  Widget _buildDropArea(BuildContext context) {
    final enable = context.watch<HomePageProvider>().isCurrentIndex(3);
    return DropFileView(
      enable: enable,
      hint: '请放入Flutter环境文件',
      onDoneValidator: (paths) {
        return getProvider(context).dropDone(context, paths);
      },
      child: _buildContent(context),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      controller: context.read<SettingsPageProvider>().scrollController,
      child: Column(children: [
        SettingItemEnvironment(
          key: context.setting.environmentKey,
          onImportLocal: () => showEnvironmentImport(context),
          onImportRemote: () => showEnvironmentImportRemote(context),
        ),
        SettingItemEnvironmentCache(
          key: context.setting.environmentCacheKey,
          onOpenCacheDirectory: getProvider(context).openCacheDirectory,
        ),
        SettingItemPlatformSort(
          key: context.setting.projectPlatformSortKey,
          onReorder: context.project.swapPlatformSort,
        ),
        SettingItemThemeMode(
          key: context.setting.themeModeKey,
          themeMode: context.theme.themeMode,
          brightness: context.theme.brightness,
          onThemeChange: context.theme.changeThemeMode,
        ),
        SettingItemThemeScheme(
          themeScheme: context.theme.themeScheme,
          onThemeSchemeChange: context.theme.showSchemeChangePicker,
        ),
      ]),
    );
  }
}

/*
* 设置页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class SettingsPageProvider extends PageProvider {
  // 滚动控制器
  final scrollController = ScrollController();

  SettingsPageProvider(super.context, super.state) {
    // 注册设置跳转方法
    context.setting.addListener(() {
      final c = context.setting.selectedKey?.currentContext;
      if (c != null) Scrollable.ensureVisible(c);
    });
  }

  // 文件拖拽完成
  Future<String?> dropDone(BuildContext context, List<String> paths) async {
    if (paths.isEmpty) return null;
    // 遍历路径集合，从路径中读取项目/环境信息
    final environments = paths.map((e) {
      if (!EnvironmentTool.isPathAvailable(e)) return null;
      return Environment()..path = e;
    }).toList()
      ..removeWhere((e) => e == null);
    // 如果没有有效内容，直接返回
    if (environments.isEmpty) return '无效内容！';
    await Future.forEach(environments.map((e) {
      return showEnvironmentImport(context, environment: e);
    }), (e) => e);
    return null;
  }

  // 打开缓存目录
  void openCacheDirectory() async {
    final path = await Tool.getCacheFilePath();
    if (path == null) return;
    OpenDir().openNativeDir(path: path);
  }
}
