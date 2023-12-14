import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

/*
* 消息通知工具
* @author wuxubaiyang
* @Time 2023/12/13 10:43
*/
class NoticeTool {
  // 展示成功消息
  static void success(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    IconData? icon,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return show(
      context,
      color: color,
      action: action,
      padding: padding,
      duration: duration,
      content: Text(message),
      constraints: constraints,
      title: title != null ? Text(title) : null,
      icon: Icon(icon ?? Icons.check_circle, color: Colors.greenAccent),
    );
  }

  // 展示错误消息
  static void error(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    IconData? icon,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return show(
      context,
      color: color,
      action: action,
      padding: padding,
      duration: duration,
      content: Text(message),
      constraints: constraints,
      title: title != null ? Text(title) : null,
      icon: Icon(icon ?? Icons.error, color: Colors.redAccent),
    );
  }

  // 展示消息提醒
  static void help(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    IconData? icon,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return show(
      context,
      color: color,
      action: action,
      padding: padding,
      duration: duration,
      content: Text(message),
      constraints: constraints,
      title: title != null ? Text(title) : null,
      icon: Icon(icon ?? Icons.help, color: Colors.blueAccent),
    );
  }

  // 展示消息
  static void show(
    BuildContext context, {
    required Widget content,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    Widget? action,
    Widget? title,
    Widget? icon,
    Color? color,
  }) {
    return AnimatedSnackBar(
      animationDuration: const Duration(milliseconds: 200),
      snackBarStrategy: const ColumnSnackBarStrategy(gap: 4),
      duration: duration ?? const Duration(milliseconds: 2000),
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
      builder: (_) => CustomNoticeView(
        icon: icon,
        color: color,
        title: title,
        action: action,
        padding: padding,
        content: content,
        constraints: constraints,
      ),
    ).show(context);
  }
}

/*
* 自定义消息模板
* @author wuxubaiyang
* @Time 2023/12/14 14:34
*/
class CustomNoticeView extends StatelessWidget {
  // 消息图标
  final Widget? icon;

  // 主题色
  final Color? color;

  // 标题
  final Widget? title;

  // 消息
  final Widget content;

  // 尺寸约束
  final BoxConstraints constraints;

  // 内间距
  final EdgeInsetsGeometry padding;

  // 动作按钮（只允许一个）
  final Widget? action;

  const CustomNoticeView({
    super.key,
    required this.content,
    this.icon,
    this.color,
    this.title,
    this.action,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  })  : padding = const EdgeInsets.all(14),
        constraints = const BoxConstraints(
            minHeight: 65, minWidth: 180, maxHeight: 120, maxWidth: 340);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 6,
      child: Container(
        padding: padding,
        constraints: constraints,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            icon ?? const SizedBox(),
            const SizedBox(width: 14),
          ],
          Expanded(child: _buildContent(context)),
          if (action != null) ...[
            const SizedBox(width: 8),
            action ?? const SizedBox(),
          ],
        ]),
      ),
    );
  }

  // 构建消息内容
  Widget _buildContent(BuildContext context) {
    final hasTitle = title != null;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium ?? const TextStyle(),
          child: title ?? const SizedBox(),
        ),
        if (hasTitle) const SizedBox(height: 4),
        DefaultTextStyle(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: (theme.textTheme.bodyMedium ?? const TextStyle())
              .copyWith(color: hasTitle ? Colors.grey : null),
          child: content,
        ),
      ],
    );
  }
}
