import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/environment/import_local.dart';
import 'package:flutter_manager/widget/dialog/environment/import_remote.dart';
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
  SettingsPage({super.key, super.state});

  @override
  SettingsPageProvider createProvider(
          BuildContext context, GoRouterState? state) =>
      SettingsPageProvider(context, state);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
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
        return pageProvider.dropDone(context, paths);
      },
      child: _buildContent(context),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      controller: pageProvider.scrollController,
      child: Column(children: [
        // 环境设置
        Selector<EnvironmentProvider, List<Environment>>(
          selector: (_, provider) => provider.environments,
          builder: (_, environments, __) {
            return SettingItemEnvironment(
              environments: environments,
              onReorder: context.env.reorder,
              onRemove: pageProvider.removeEnvironment,
              onRefresh: pageProvider.refreshEnvironment,
              settingKey: context.setting.environmentKey,
              removeValidator: pageProvider.removeEnvironmentConfirm,
              onImportLocal: () => showImportEnvLocal(context),
              onEdit: (e) => showImportEnvLocal(context, env: e),
              onImportRemote: () => showImportEnvRemote(context),
            );
          },
        ),
        // 环境缓存设置
        Consumer<EnvironmentProvider>(
          builder: (_, provider, __) {
            return FutureBuilder<DownloadEnvInfo>(
              future: EnvironmentTool.getDownloadInfo(),
              builder: (_, snap) {
                return SettingItemEnvironmentCache(
                  downloadFileInfo: snap.data,
                  settingKey: context.setting.environmentCacheKey,
                  onOpenCacheDirectory: pageProvider.openCacheDirectory,
                );
              },
            );
          },
        ),
        // 平台排序设置
        Selector<ProjectProvider, List<PlatformType>>(
          selector: (_, provider) => provider.platforms,
          builder: (_, platforms, __) {
            return SettingItemPlatformSort(
              platforms: platforms,
              onReorder: context.project.swapPlatformSort,
              settingKey: context.setting.projectPlatformSortKey,
            );
          },
        ),
        // 主题设置
        Selector<ThemeProvider, ThemeMode>(
          selector: (_, provider) => provider.themeMode,
          builder: (_, themeMode, __) {
            return SettingItemThemeMode(
              themeMode: themeMode,
              brightness: context.theme.brightness,
              settingKey: context.setting.themeModeKey,
              onThemeChange: context.theme.changeThemeMode,
            );
          },
        ),
        // 主题配色设置
        Selector<ThemeProvider, ThemeScheme>(
          selector: (_, provider) => provider.themeScheme,
          builder: (_, themeScheme, __) {
            return SettingItemThemeScheme(
              themeScheme: themeScheme,
              settingKey: context.setting.themeSchemeKey,
              onThemeSchemeChange: () =>
                  context.theme.showSchemeChangePicker(context),
            );
          },
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

  // 移除环境
  void removeEnvironment(Environment environment) {
    context.env.remove(environment);
    showNoticeSuccess(
      '${environment.title} 环境已移除',
      actions: [
        TextButton(
          onPressed: () {
            context.env.update(environment);
          },
          child: Text('撤销'),
        )
      ],
    );
  }

  // 移除环境确认
  Future<bool> removeEnvironmentConfirm(Environment environment) async {
    final result = context.env.removeValidator(environment);
    if (result == null) return true;
    showNoticeError(result, title: '环境移除失败');
    return false;
  }

  // 刷新环境
  void refreshEnvironment(Environment environment) async {
    final result = await context.env.refresh(environment).loading(context);
    if (!context.mounted) return;
    showNoticeError('$result', title: '刷新失败');
    context.env.update(environment);
  }

  // 文件拖拽完成
  Future<String?> dropDone(BuildContext context, List<String> paths) async {
    if (paths.isEmpty) return null;
    // 遍历路径集合，从路径中读取项目/环境信息
    final environments = paths.map((e) {
      if (!EnvironmentTool.isAvailable(e)) return null;
      return Environment()..path = e;
    }).toList()
      ..removeWhere((e) => e == null);
    // 如果没有有效内容，直接返回
    if (environments.isEmpty) return '无效内容！';
    await Future.forEach(environments.map((e) {
      return showImportEnvLocal(context, env: e);
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
