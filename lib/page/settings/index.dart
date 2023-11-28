import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/page/settings/environment_list.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/dialog/environment.dart';
import 'package:flutter_manager/widget/dialog/environment_remote.dart';
import 'package:flutter_manager/widget/dialog/scheme.dart';
import 'package:flutter_manager/widget/scheme_item.dart';
import 'package:flutter_manager/widget/setting_item.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFlutterEnvironment(context),
            _buildThemeMode(context),
            _buildThemeScheme(context),
          ],
        ),
      ),
    );
  }

  // 构建Flutter环境设置项
  Widget _buildFlutterEnvironment(BuildContext context) {
    return SettingItem(
      index: 0,
      label: 'Flutter环境',
      content: const EnvironmentList(),
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

  // 构建主题模式设置项
  Widget _buildThemeMode(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    return SettingItem(
      index: 1,
      label: '配色模式',
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
      index: 2,
      label: '应用配色',
      content: Text(scheme.label),
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
class SettingsPageProvider extends ChangeNotifier {}
