import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/page/home/index.dart';
import 'package:flutter_manager/page/settings/environment_list.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/dialog/environment.dart';
import 'package:flutter_manager/widget/dialog/environment_remote.dart';
import 'package:flutter_manager/widget/dialog/scheme.dart';
import 'package:flutter_manager/widget/drop_file.dart';
import 'package:flutter_manager/widget/scheme_item.dart';
import 'package:flutter_manager/widget/setting_item.dart';
import 'package:open_dir/open_dir.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 设置页
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class SettingsPage extends BasePage {
  const SettingsPage({super.key});

  @override
  bool get primary => false;

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => SettingsPageProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    context.read<SettingsPageProvider>().registerSettingsJumper(context);
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
    final enable = context.watch<HomePageProvider>().isNavigationIndex(3);
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
      child: Column(
        children: [
          _buildFlutterEnvironment(context),
          _buildFlutterEnvironmentCache(context),
          _buildThemeMode(context),
          _buildThemeScheme(context),
        ],
      ),
    );
  }

  // 构建Flutter环境设置项
  Widget _buildFlutterEnvironment(BuildContext context) {
    return SettingItem(
      label: 'Flutter环境',
      content: const EnvironmentList(),
      key: context.read<SettingProvider>().environmentKey,
      child: PopupMenuButton(
        tooltip: '添加环境',
        icon: const Icon(Icons.add_circle_outline),
        itemBuilder: (_) => [
          PopupMenuItem(
            child: const Text('本地导入'),
            onTap: () => EnvironmentImportDialog.show(context),
          ),
          PopupMenuItem(
            child: const Text('远程导入'),
            onTap: () => EnvironmentRemoteImportDialog.show(context),
          ),
        ],
      ),
    );
  }

  // 构建Flutter环境缓存设置项
  Widget _buildFlutterEnvironmentCache(BuildContext context) {
    return SettingItem(
      label: 'Flutter环境缓存',
      key: context.read<SettingProvider>().environmentCacheKey,
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
          final dir = await EnvironmentTool.getDownloadCachePath();
          if (dir != null) OpenDir().openNativeDir(path: dir);
        },
      ),
    );
  }

  // 构建主题模式设置项
  Widget _buildThemeMode(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    return SettingItem(
      label: '配色模式',
      key: context.read<SettingProvider>().themeModeKey,
      content: Text(provider.getBrightness(context).label),
      child: DropdownButton<ThemeMode>(
        value: provider.themeMode,
        items: ThemeMode.values
            .map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode.label),
                ))
            .toList(),
        onChanged: (mode) {
          if (mode == null) return;
          provider.changeThemeMode(context, mode);
        },
      ),
    );
  }

  // 构建主题色彩设置项
  Widget _buildThemeScheme(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final scheme = provider.getThemeSchemeModel(context);
    return SettingItem(
      label: '应用配色',
      content: Text(scheme.label),
      key: context.read<SettingProvider>().themeSchemeKey,
      child: ThemeSchemeItem(
        size: 40,
        scheme: scheme,
        isSelected: true,
        tooltip: '更换配色',
        onPressed: () => ThemeSchemeDialog.show(
          context,
          schemes: provider.getThemeSchemeList(context),
          current: provider.getThemeSchemeModel(context),
        ).then((value) {
          if (value != null) provider.changeThemeScheme(context, value);
        }),
      ),
    );
  }
}

/*
* 设置页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class SettingsPageProvider extends ChangeNotifier {
  // 注册监听回调
  VoidCallback? _settingListener;

  // 滚动控制器
  final scrollController = ScrollController();

  // 注册设置跳转监听
  void registerSettingsJumper(BuildContext context) {
    if (_settingListener != null) return;
    final provider = context.read<SettingProvider>();
    provider.addListener(_settingListener ??= () {
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
      return EnvironmentImportDialog.show(context, environment: e);
    }), (e) => e);
    return null;
  }
}
