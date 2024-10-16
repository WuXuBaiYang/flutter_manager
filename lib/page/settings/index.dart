import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/settings/environment_list.dart';
import 'package:flutter_manager/page/settings/platform_sort_list.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/dialog/environment_import.dart';
import 'package:flutter_manager/widget/dialog/environment_import_remote.dart';
import 'package:flutter_manager/widget/drop_file.dart';
import 'package:flutter_manager/page/settings/setting_item.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:open_dir/open_dir.dart';

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
    final provider = context.read<SettingsPageProvider>();
    final enable = context.watch<HomePageProvider>().isCurrentIndex(3);
    return DropFileView(
      enable: enable,
      hint: '请放入Flutter环境文件',
      onDoneValidator: (paths) {
        return provider.dropDone(context, paths);
      },
      child: _buildContent(context),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      controller: context.read<SettingsPageProvider>().scrollController,
      child: Column(children: [
        _buildFlutterEnvironment(context),
        _buildFlutterEnvironmentCache(context),
        _buildProjectPlatformSort(context),
        _buildThemeMode(context),
        _buildThemeScheme(context),
      ]),
    );
  }

  // 构建Flutter环境设置项
  Widget _buildFlutterEnvironment(BuildContext context) {
    return SettingItem(
      label: 'Flutter环境',
      content: const EnvironmentList(),
      key: context.setting.environmentKey,
      child: PopupMenuButton(
        tooltip: '添加环境',
        icon: const Icon(Icons.add_circle_outline),
        itemBuilder: (_) => [
          PopupMenuItem(
            child: const Text('本地导入'),
            onTap: () => showEnvironmentImport(context),
          ),
          PopupMenuItem(
            child: const Text('远程导入'),
            onTap: () => showEnvironmentImportRemote(context),
          ),
        ],
      ),
    );
  }

  // 构建Flutter环境缓存设置项
  Widget _buildFlutterEnvironmentCache(BuildContext context) {
    return SettingItem(
      label: 'Flutter环境缓存',
      key: context.setting.environmentCacheKey,
      content: Selector<EnvironmentProvider, List<Environment>>(
        selector: (_, provider) => provider.environments,
        builder: (_, environments, __) {
          return FutureProvider<DownloadFileInfoTuple?>(
            initialData: null,
            updateShouldNotify: (_, __) => true,
            create: (_) => EnvironmentTool.getDownloadFileInfo(),
            builder: (context, _) {
              final info = context.watch<DownloadFileInfoTuple?>();
              final cacheCount = '${info?.count ?? 0}个缓存文件';
              final cacheSize = FileTool.formatSize(info?.totalSize ?? 0);
              return Text('$cacheCount/$cacheSize');
            },
          );
        },
      ),
      child: IconButton(
        tooltip: '打开缓存目录',
        icon: const Icon(Icons.file_open_outlined),
        onPressed: () async {
          final path = await Tool.getCacheFilePath();
          if (path == null) return;
          OpenDir().openNativeDir(path: path);
        },
      ),
    );
  }

  // 构建项目平台排序设置项
  Widget _buildProjectPlatformSort(BuildContext context) {
    return SettingItem(
      label: '项目平台排序',
      key: context.setting.projectPlatformSortKey,
      content: const PlatformSortList(),
    );
  }

  // 构建主题模式设置项
  Widget _buildThemeMode(BuildContext context) {
    final provider = context.theme;
    return SettingItem(
      label: '配色模式',
      key: context.setting.themeModeKey,
      content: Text(provider.brightness.label),
      child: DropdownButton<ThemeMode>(
        value: provider.themeMode,
        items: ThemeMode.values
            .map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode.label),
                ))
            .toList(),
        onChanged: provider.changeThemeMode,
      ),
    );
  }

  // 构建主题色彩设置项
  Widget _buildThemeScheme(BuildContext context) {
    final provider = context.theme;
    final themeScheme = provider.themeScheme;
    return SettingItem(
      label: '应用配色',
      content: Text(themeScheme.label),
      key: context.setting.themeSchemeKey,
      child: ThemeSchemeItem(
        size: 40,
        themeScheme: themeScheme,
        isSelected: true,
        tooltip: '更换配色',
        onPressed: () => showSchemePicker(
          context,
          current: themeScheme,
          themeSchemes: provider.getThemeSchemeList(),
        ).then(provider.changeThemeScheme),
      ),
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
    final provider = context.setting;
    provider.addListener(() {
      final context = provider.selectedKey?.currentContext;
      if (context != null) Scrollable.ensureVisible(context);
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
}
