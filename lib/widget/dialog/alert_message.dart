import 'package:flutter/material.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示消息确认弹窗
Future<bool?> showAlertMessage(
  BuildContext context, {
  String? title,
  required String content,
  String? confirmText,
  String? cancelText,
  Function? confirm,
  Function? cancel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertMessageDialog(
      title: title,
      content: content,
      confirm: confirm,
      cancel: cancel,
    ),
  );
}

/*
* 消息确认弹窗
* @author wuxubaiyang
* @Time 2023/12/15 9:00
*/
class AlertMessageDialog extends StatelessWidget {
  // 标题
  final String? title;

  // 内容
  final String content;

  // 确认按钮事件
  final Function? confirm;

  // 取消按钮事件
  final Function? cancel;

  const AlertMessageDialog({
    super.key,
    this.title,
    required this.content,
    this.confirm,
    this.cancel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title == null ? null : Text(title!),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            cancel?.call();
            Navigator.maybePop(context);
          },
        ),
        TextButton(
          child: const Text('确认'),
          onPressed: () {
            confirm?.call();
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
