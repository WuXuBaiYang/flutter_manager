import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/theme_scheme.dart';
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
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFlutterEnvironment(),
            _buildThemeMode(context),
            _buildThemeScheme(context),
          ],
        ),
      ),
    );
  }

  // 构建Flutter环境设置项
  Widget _buildFlutterEnvironment() {
    return ListTile(
      title: const Text('Flutter环境'),
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
        icon: ThemeSchemeView(item: scheme),
        onPressed: () => _showThemeSchemeDialog(context),
      ),
    );
  }

  // 显示主题色彩选择弹窗
  Future<void> _showThemeSchemeDialog(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final schemes = provider.getThemeSchemeList(context);
    return showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Card(
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 240),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: schemes.length,
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 45,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (_, index) {
                  final item = schemes[index];
                  return IconButton.outlined(
                    tooltip: item.label,
                    icon: ThemeSchemeView(item: item),
                    onPressed: () {
                      provider.changeThemeScheme(context, item);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/*
* 设置页状态管理
* @author wuxubaiyang
* @Time 2023/11/24 14:25
*/
class SettingsProvider extends ChangeNotifier {}
