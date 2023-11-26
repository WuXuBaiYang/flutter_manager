import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/dialog/environment.dart';
import 'package:flutter_manager/widget/dialog/scheme.dart';
import 'package:flutter_manager/widget/scheme_item.dart';
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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
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
    return ListTile(
      isThreeLine: true,
      title: const Text('Flutter环境'),
      trailing: IconButton.outlined(
        icon: const Icon(Icons.add),
        onPressed: () => EnvironmentLocalImportDialog.show(context),
      ),
      subtitle: _buildFlutterEnvironmentList(context),
    );
  }

  // 构建Flutter环境列表
  Widget _buildFlutterEnvironmentList(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        const Size.fromHeight(240),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Selector<EnvironmentProvider, List<Environment>>(
          selector: (_, provider) => provider.environments,
          builder: (_, environments, __) {
            return ListView.separated(
              shrinkWrap: true,
              itemCount: environments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final item = environments[index];
                return ListTile(
                  title: Text('Flutter · ${item.version} · ${item.channel}'),
                  subtitle: Text(item.path),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   onPressed: () {},
                  // ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // 构建主题模式设置项
  Widget _buildThemeMode(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    return ListTile(
      title: const Text('配色模式'),
      subtitle: Text(provider.getBrightness(context).label),
      trailing: DropdownButton<ThemeMode>(
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
    return ListTile(
      title: const Text('应用配色'),
      subtitle: Text(scheme.label),
      trailing: IconButton.outlined(
        icon: ThemeSchemeItem(item: scheme),
        onPressed: () => ThemeSchemeDialog.show(
          context,
          schemes: provider.getThemeSchemeList(context),
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
class SettingsProvider extends ChangeNotifier {}
