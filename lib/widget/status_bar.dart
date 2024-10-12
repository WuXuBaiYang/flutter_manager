import 'package:flutter/material.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/provider/window.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:window_manager/window_manager.dart';

/*
* 状态条
* @author wuxubaiyang
* @Time 2023/12/13 15:59
*/
class StatusBar extends StatelessWidget implements PreferredSizeWidget {
  // 动作按钮集合
  final List<Widget> actions;

  const StatusBar({
    super.key,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) {
        final brightness = theme.brightness;
        return DragToMoveArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                ...actions,
                const Spacer(),
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: WindowCaptionButton.minimize(
                    brightness: brightness,
                    onPressed: windowManager.minimize,
                  ),
                ),
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: _buildMaximizeButton(brightness),
                ),
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: WindowCaptionButton.close(
                    brightness: brightness,
                    onPressed: windowManager.close,
                  ),
                ),
              ].expand<Widget>((child) {
                return [child, const SizedBox(width: 4)];
              }).toList(),
            ),
          ),
        );
      },
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
            onPressed: context.window.unMaximize,
          );
        }
        return WindowCaptionButton.maximize(
          brightness: brightness,
          onPressed: context.window.maximize,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
