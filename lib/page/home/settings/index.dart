import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/environment/import_local.dart';
import 'package:flutter_manager/widget/dialog/environment/import_remote.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:open_dir/open_dir.dart';

import 'settings.dart';

/*
* 首页-设置分页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class HomeSettingsView extends ProviderView<HomeSettingsProvider> {
  HomeSettingsView({super.key});

  @override
  HomeSettingsProvider? createProvider(BuildContext context) =>
      HomeSettingsProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      controller: provider.scrollController,
      child: Column(children: [
        // 环境设置
        Selector<EnvironmentProvider, List<Environment>>(
          selector: (_, provider) => provider.environments,
          builder: (_, environments, __) {
            return SettingItemEnvironment(
              environments: environments,
              onReorder: context.env.reorder,
              onRemove: provider.removeEnvironment,
              onRefresh: provider.refreshEnvironment,
              settingKey: context.setting.environmentKey,
              removeValidator: provider.removeEnvironmentConfirm,
              onImportLocal: () => showImportEnvLocal(context),
              onEdit: (e) => showImportEnvLocal(context, env: e),
              onImportRemote: () => showImportEnvRemote(context),
            );
          },
        ),
        // 环境缓存设置
        Consumer<EnvironmentProvider>(
          builder: (_, ___, __) {
            return FutureBuilder<DownloadEnvInfo>(
              future: EnvironmentTool.getDownloadInfo(),
              builder: (_, snap) {
                return SettingItemEnvironmentCache(
                  downloadFileInfo: snap.data,
                  settingKey: context.setting.environmentCacheKey,
                  onOpenCacheDirectory: provider.openCacheDirectory,
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

class HomeSettingsProvider extends BaseProvider {
  // 滚动控制器
  final scrollController = ScrollController();

  HomeSettingsProvider(super.context) {
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

  // 打开缓存目录
  void openCacheDirectory() async {
    final path = await Tool.getCacheFilePath();
    if (path == null) return;
    OpenDir().openNativeDir(path: path);
  }
}
