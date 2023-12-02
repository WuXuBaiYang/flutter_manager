import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/provider/window.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:window_manager/window_manager.dart';

/*
* 页面基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class BasePage extends StatelessWidget {
  // 是否为主页面
  final bool primary;

  const BasePage({
    super.key,
    this.primary = true,
  });

  List<SingleChildWidget> loadProviders(BuildContext context) => [];

  @override
  Widget build(BuildContext context) {
    final providers = loadProviders(context);
    if (providers.isEmpty) return _buildContent(context);
    return MultiProvider(
      providers: providers,
      builder: (context, _) {
        return _buildContent(context);
      },
    );
  }

  Widget buildWidget(BuildContext context);

  // 构建内容主体
  Widget _buildContent(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (primary) _buildStatusBar(context),
          Expanded(child: buildWidget(context)),
        ],
      ),
    );
  }

  // 构建状态条
  Widget _buildStatusBar(BuildContext context) {
    final brightness = context.read<ThemeProvider>().getBrightness(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: DragToMoveArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Spacer(),
              WindowCaptionButton.minimize(
                brightness: brightness,
                onPressed: windowManager.minimize,
              ),
              _buildMaximizeButton(brightness),
              WindowCaptionButton.close(
                brightness: brightness,
                onPressed: windowManager.close,
              ),
            ].expand<Widget>((child) {
              return [child, const SizedBox(width: 4)];
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 构建窗口最大化按钮
  Widget _buildMaximizeButton(Brightness brightness) {
    return Selector<WindowProvider, bool>(
      selector: (_, provider) => provider.maximized,
      builder: (context, isMaximized, __) {
        if (isMaximized) {
          return WindowCaptionButton.unmaximize(
            brightness: brightness,
            onPressed: context.read<WindowProvider>().unMaximize,
          );
        }
        return WindowCaptionButton.maximize(
          brightness: brightness,
          onPressed: context.read<WindowProvider>().maximize,
        );
      },
    );
  }
}
