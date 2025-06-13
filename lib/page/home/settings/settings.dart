import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/scheme_picker.dart';
import 'package:jtech_base/jtech_base.dart';
import 'item.dart';

// 异步移除验证回调
typedef AsyncRemoveValidator<T> = Future<bool> Function(T environment);

/*
* 设置项-环境设置
* @author wuxubaiyang
* @Time 2024/10/10 16:25
*/
class SettingItemEnvironment extends StatelessWidget {
  // 设置key
  final Key settingKey;

  // 环境列表
  final List<Environment> environments;

  // 本地导入回调
  final VoidCallback? onImportLocal;

  // 远程导入回调
  final VoidCallback? onImportRemote;

  // 约束
  final BoxConstraints constraints;

  // 排序回调
  final ReorderCallback onReorder;

  // 环境移除回调
  final ValueChanged<Environment>? onRemove;

  // 环境移除异步确认
  final AsyncRemoveValidator<Environment> removeValidator;

  // 环境刷新回调
  final ValueChanged<Environment>? onRefresh;

  // 环境编辑回调
  final ValueChanged<Environment>? onEdit;

  const SettingItemEnvironment({
    super.key,
    required this.onReorder,
    required this.settingKey,
    required this.environments,
    required this.removeValidator,
    this.onEdit,
    this.onRemove,
    this.onRefresh,
    this.onImportLocal,
    this.onImportRemote,
    this.constraints = const BoxConstraints(maxHeight: 240),
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: settingKey,
      label: 'Flutter环境',
      content: _buildContent(context),
      child: _buildAddButton(context),
    );
  }

  // 操作按钮
  Widget _buildAddButton(BuildContext context) {
    return PopupMenuButton(
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
    );
  }

  // 构建环境列表
  Widget _buildContent(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: _buildList(context),
      ),
    );
  }

  // 构建环境列表
  Widget _buildList(BuildContext context) {
    if (environments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text('暂无环境'),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      onReorder: onReorder,
      itemCount: environments.length,
      buildDefaultDragHandles: false,
      proxyDecorator: (_, index, _) {
        final item = environments[index];
        return _buildListItemProxy(item);
      },
      itemBuilder: (_, index) {
        final item = environments[index];
        return _buildListItem(context, item, index);
      },
    );
  }

  // 构建Flutter环境列表项
  Widget _buildListItem(BuildContext context, Environment item, int index) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove?.call(item),
      confirmDismiss: (_) => removeValidator(item),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 14),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.path),
        trailing: _buildListItemOptions(context, item, index),
      ),
    );
  }

  // 构建Flutter环境列表项选项
  Widget _buildListItemOptions(
      BuildContext context, Environment item, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!EnvironmentTool.isAvailable(item.path)) ...[
          const Tooltip(
            message: '环境不存在',
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
        ],
        IconButton(
          iconSize: 18,
          tooltip: '编辑环境',
          icon: const Icon(Icons.edit),
          onPressed: () => onEdit?.call(item),
        ),
        IconButton(
          iconSize: 18,
          tooltip: '刷新环境',
          icon: const Icon(Icons.refresh),
          onPressed: () => onRefresh?.call(item),
        ),
        const SizedBox(width: 8),
        ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
      ],
    );
  }

  // 构建Flutter环境列表项代理
  Widget _buildListItemProxy(Environment item) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.path),
        trailing: const Icon(Icons.drag_handle),
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
  // 设置key
  final Key settingKey;

  // 下载文件记录
  final DownloadEnvInfo? downloadFileInfo;

  // 打开缓存目录回调
  final VoidCallback? onOpenCacheDirectory;

  const SettingItemEnvironmentCache({
    super.key,
    required this.settingKey,
    this.downloadFileInfo,
    this.onOpenCacheDirectory,
  });

  @override
  Widget build(BuildContext context) {
    final cacheCount = '${downloadFileInfo?.count ?? 0}个缓存文件';
    final cacheSize = FileTool.formatSize(downloadFileInfo?.totalFileSize ?? 0);
    return SettingItem(
      key: settingKey,
      label: 'Flutter环境缓存',
      content: Text('$cacheCount/$cacheSize'),
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
  // 设置key
  final Key settingKey;

  // 排序列表
  final List<PlatformType> platforms;

  // 约束
  final BoxConstraints constraints;

  // 重排序回调
  final ReorderCallback onReorder;

  const SettingItemPlatformSort({
    super.key,
    required this.platforms,
    required this.onReorder,
    required this.settingKey,
    this.constraints = const BoxConstraints.tightFor(height: 55),
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: settingKey,
      label: '项目平台排序',
      content: ConstrainedBox(
        constraints: constraints,
        child: _buildPlatformList(context),
      ),
    );
  }

  // 构建平台列表
  Widget _buildPlatformList(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: onReorder,
      itemCount: platforms.length,
      buildDefaultDragHandles: false,
      scrollDirection: Axis.horizontal,
      proxyDecorator: (_, index, _) {
        final item = platforms[index];
        return Material(
          color: Colors.transparent,
          child: _buildPlatformListItem(context, item),
        );
      },
      itemBuilder: (_, i) {
        final item = platforms[i];
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
  // 设置key
  final Key settingKey;

  // 当前主题模式
  final ThemeMode themeMode;

  // 当前亮色状态
  final Brightness brightness;

  // 主题模式改变回调
  final ValueChanged<ThemeMode?>? onThemeChange;

  const SettingItemThemeMode({
    super.key,
    required this.settingKey,
    this.onThemeChange,
    this.themeMode = ThemeMode.system,
    this.brightness = Brightness.light,
  });

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      key: settingKey,
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
  // 设置key
  final Key settingKey;

  // 当前主题配色
  final FlexScheme themeScheme;

  // 主题配色改变回调
  final VoidCallback? onThemeSchemeChange;

  const SettingItemThemeScheme({
    super.key,
    required this.settingKey,
    required this.themeScheme,
    this.onThemeSchemeChange,
  });

  @override
  Widget build(BuildContext context) {
    final schemeData = context.theme.themeSchemes[themeScheme];
    final schemeColor = switch (Theme.of(context).brightness) {
      Brightness.light => schemeData?.light,
      Brightness.dark => schemeData?.dark,
    };
    if (schemeColor == null) return SizedBox();
    return SettingItem(
      key: settingKey,
      label: '应用配色',
      child: ThemeSchemeItem(
        size: 40,
        isSelected: true,
        tooltip: '更换配色',
        primary: schemeColor.primary,
        onPressed: onThemeSchemeChange,
        secondary: schemeColor.secondary,
      ),
    );
  }
}
