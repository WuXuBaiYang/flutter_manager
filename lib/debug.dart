import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 调试
* @author wuxubaiyang
* @Time 2024/7/31 18:06
*/
class Debug {
  // 构建调试按钮
  static Widget? buildDebugButton(BuildContext context) {
    if (!kDebugMode) return null;
    return FloatingActionButton(
      onPressed: () => debug(context),
      child: const Icon(FontAwesomeIcons.bug),
    );
  }

  static Future<void> debug(BuildContext context) async {
  }
}