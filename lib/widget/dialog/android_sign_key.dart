import 'package:flutter/material.dart';

// 展示android签名创建弹窗
Future<bool?> showAndroidSignKey(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AndroidSignKeyDialog(),
  );
}

/*
* android签名创建弹窗
* @author wuxubaiyang
* @Time 2023/12/15 9:00
*/
class AndroidSignKeyDialog extends StatelessWidget {
  const AndroidSignKeyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建Android签名'),
      content: _buildContent(context),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {},
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return SizedBox();
  }
}
