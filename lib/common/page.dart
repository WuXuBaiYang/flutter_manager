import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:window_manager/window_manager.dart';

/*
* 页面基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class BasePage extends StatelessWidget {
  // 标题
  final Widget? title;

  // 前置
  final Widget? leading;

  // 动作按钮（接在默认操作按钮左边）
  final List<Widget> actions;

  const BasePage({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
  });

  List<SingleChildWidget> get providers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      builder: (context, _) {
        return Consumer<ThemeProvider>(
          builder: (_, provider, __) {
            return Material(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusBar(context, provider),
                  Expanded(child: buildWidget(context)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildWidget(BuildContext context);

  // 构建状态条
  Widget _buildStatusBar(BuildContext context, ThemeProvider provider) {
    final brightness = provider.getBrightness(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: DragToMoveArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 8),
              leading ?? const SizedBox(),
              title ?? const SizedBox(),
              const Spacer(),
              ...actions,
              const SizedBox(width: 14),
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
    return StatefulBuilder(
      builder: (_, setState) {
        return FutureBuilder<bool>(
          future: windowManager.isMaximized(),
          builder: (_, snap) {
            if (snap.data == true) {
              return WindowCaptionButton.unmaximize(
                brightness: brightness,
                onPressed: () => setState(() {
                  windowManager.unmaximize();
                }),
              );
            }
            return WindowCaptionButton.maximize(
              brightness: brightness,
              onPressed: () => setState(() {
                windowManager.maximize();
              }),
            );
          },
        );
      },
    );
  }
}
