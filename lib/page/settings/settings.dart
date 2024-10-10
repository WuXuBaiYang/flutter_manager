import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:jtech_base/jtech_base.dart';
import 'environment_list.dart';
import 'setting_item.dart';

/*
* 设置项-环境设置
* @author wuxubaiyang
* @Time 2024/10/10 16:25
*/
class SettingItemEnvironment extends StatelessWidget {
  // 本地导入回调
  final VoidCallback? onImportLocal;

  // 远程导入回调
  final VoidCallback? onImportRemote;

  const SettingItemEnvironment({
    super.key,
    this.onImportLocal,
    this.onImportRemote,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: key,
      label: 'Flutter环境',
      content: const EnvironmentList(),
      child: PopupMenuButton(
        tooltip: '添加环境',
        icon: const Icon(Icons.add_circle_outline),
        itemBuilder: (_) => [
          PopupMenuItem(
            onTap: onImportLocal,
            child: const Text('本地导入'),
          ),
          PopupMenuItem(
            onTap: onImportRemote,
            child: const Text('远程导入'),
          ),
        ],
      ),
    );
  }
}

/*
* 设置项-环境缓存设置
* @author wuxubaiyang
* @Time 2024/10/10 16:30
*/
class SettingItemEnvironmentCache extends StatelessWidget {
  // 打开缓存目录回调
  final VoidCallback? onOpenCacheDirectory;

  const SettingItemEnvironmentCache({
    super.key,
    this.onOpenCacheDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: key,
      label: 'Flutter环境缓存',
      content: Consumer<EnvironmentProvider>(
        builder: (_, provider, __) {
          return FutureBuilder<DownloadFileInfoTuple>(
            future: EnvironmentTool.getDownloadFileInfo(),
            builder: (_, snap) {
              final info = snap.data;
              final cacheCount = '${info?.count ?? 0}个缓存文件';
              final cacheSize = FileTool.formatSize(info?.totalSize ?? 0);
              return Text('$cacheCount/$cacheSize');
            },
          );
        },
      ),
      child: IconButton(
        tooltip: '打开缓存目录',
        onPressed: onOpenCacheDirectory,
        icon: const Icon(Icons.file_open_outlined),
      ),
    );
  }
}

/*
* 设置项-平台排序设置
* @author wuxubaiyang
* @Time 2024/10/10 16:34
*/
class SettingItemPlatformSort extends StatelessWidget {
  // 约束
  final BoxConstraints constraints;

  // 重排序回调
  final ReorderCallback onReorder;

  const SettingItemPlatformSort({
    super.key,
    required this.onReorder,
    this.constraints = const BoxConstraints.tightFor(height: 55),
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: key,
      label: '项目平台排序',
      content: ConstrainedBox(
        constraints: constraints,
        child: _buildPlatformList(context),
      ),
    );
  }

  // 构建平台列表
  Widget _buildPlatformList(BuildContext context) {
    return Selector<ProjectProvider, List<PlatformType>>(
      selector: (_, provider) => provider.platformSort,
      builder: (_, platformSort, __) {
        return ReorderableListView.builder(
          onReorder: onReorder,
          itemCount: platformSort.length,
          buildDefaultDragHandles: false,
          scrollDirection: Axis.horizontal,
          proxyDecorator: (_, index, ___) {
            final item = platformSort[index];
            return Material(
              color: Colors.transparent,
              child: _buildPlatformListItem(context, item),
            );
          },
          itemBuilder: (_, i) {
            final item = platformSort[i];
            return ReorderableDragStartListener(
              index: i,
              key: ValueKey(item.index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPlatformListItem(context, item),
              ),
            );
          },
        );
      },
    );
  }

  // 构建平台列表项
  Widget _buildPlatformListItem(BuildContext context, PlatformType platform) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return ActionChip(
      label: Text(platform.name, style: textStyle),
      avatar: Icon(Icons.drag_handle, color: textStyle?.color),
    );
  }
}

/*
* 设置项-主题配色模式
* @author wuxubaiyang
* @Time 2024/10/10 16:43
*/
class SettingItemThemeMode extends StatelessWidget {
  // 当前主题模式
  final ThemeMode themeMode;

  // 当前亮色状态
  final Brightness brightness;

  // 主题模式改变回调
  final ValueChanged<ThemeMode?>? onThemeChange;

  const SettingItemThemeMode({
    super.key,
    this.onThemeChange,
    this.themeMode = ThemeMode.system,
    this.brightness = Brightness.light,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: key,
      label: '配色模式',
      content: Text(brightness.label),
      child: DropdownButton<ThemeMode>(
        value: themeMode,
        onChanged: onThemeChange,
        items: ThemeMode.values
            .map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode.label),
                ))
            .toList(),
      ),
    );
  }
}

/*
* 设置项-主题配色设置
* @author wuxubaiyang
* @Time 2024/10/10 16:47
*/
class SettingItemThemeScheme extends StatelessWidget {
  // 当前主题配色
  final ThemeScheme themeScheme;

  // 主题配色改变回调
  final VoidCallback? onThemeSchemeChange;

  const SettingItemThemeScheme({
    super.key,
    required this.themeScheme,
    this.onThemeSchemeChange,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: key,
      label: '应用配色',
      content: Text(themeScheme.label),
      child: ThemeSchemeItem(
        size: 40,
        isSelected: true,
        tooltip: '更换配色',
        themeScheme: themeScheme,
        onPressed: onThemeSchemeChange,
      ),
    );
  }
}
