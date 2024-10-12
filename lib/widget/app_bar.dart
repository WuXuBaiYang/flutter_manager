import 'package:flutter/material.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/provider/window.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:window_manager/window_manager.dart';

/*
* 自定义标题栏
* @author wuxubaiyang
* @Time 2023/12/13 15:59
*/
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 标题
  final Widget? title;

  // 左侧控件
  final Widget? leading;

  // 动作按钮集合
  final List<Widget> actions;

  // 背景色
  final Color? backgroundColor;

  // 是否自动显示返回按钮
  final bool automaticallyImplyLeading;

  // 操作按钮大小
  final Size actionSize;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.backgroundColor,
    this.actions = const [],
    this.actionSize = const Size(40, 35),
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) {
        final brightness = theme.brightness;
        return DragToMoveArea(
          child: AppBar(
            title: title,
            leading: leading,
            backgroundColor: backgroundColor,
            automaticallyImplyLeading: automaticallyImplyLeading,
            actions: [
              ...actions,
              SizedBox(width: 14),
              SizedBox.fromSize(
                size: actionSize,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: WindowCaptionButton.minimize(
                    brightness: brightness,
                    onPressed: windowManager.minimize,
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox.fromSize(
                size: actionSize,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: _buildMaximizeButton(brightness),
                ),
              ),
              SizedBox(width: 8),
              SizedBox.fromSize(
                size: actionSize,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(4),
                  child: WindowCaptionButton.close(
                    brightness: brightness,
                    onPressed: windowManager.close,
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
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
