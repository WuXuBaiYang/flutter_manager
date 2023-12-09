import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/snack.dart';

/*
* 代理基类
* @author wuxubaiyang
* @Time 2023/11/24 11:14
*/
abstract class BaseProvider extends ChangeNotifier {
  // context
  final BuildContext context;

  BaseProvider(this.context);

  // 展示消息
  void showMessage(String message) =>
      SnackTool.showMessage(context, message: message);
}
