import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

/*
* 消息通知工具
* @author wuxubaiyang
* @Time 2023/12/13 10:43
*/
class NoticeTool {
  // 展示成功消息
  static void success(BuildContext context, String title,
          {required String message, Duration? duration}) =>
      _snack(context, title,
          message: message, type: ContentType.success, duration: duration);

  // 展示警告消息
  static void warning(BuildContext context, String title,
          {required String message, Duration? duration}) =>
      _snack(context, title,
          message: message, type: ContentType.warning, duration: duration);

  // 展示错误消息
  static void failure(BuildContext context, String title,
          {required String message, Duration? duration}) =>
      _snack(context, title,
          message: message, type: ContentType.failure, duration: duration);

  // 展示帮助消息
  static void help(BuildContext context, String title,
          {required String message, Duration? duration}) =>
      _snack(context, title,
          message: message, type: ContentType.help, duration: duration);

  // 展示snack消息
  static void _snack(
    BuildContext context,
    String title, {
    required String message,
    required ContentType type,
    Duration? duration,
  }) {
    duration ??= const Duration(milliseconds: 2000);
    final content = AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
    );
    final snackBar = SnackBar(
      elevation: 0,
      content: content,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
