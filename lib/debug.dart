import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
* 调试
* @author wuxubaiyang
* @Time 2024/7/31 18:06
*/
class Debug {
  // 构建调试按钮
  static Widget buildDebugButton(BuildContext context) {
    if (!kDebugMode) return const SizedBox();
    return IconButton(
      onPressed: () => debug(context),
      icon: const Icon(Icons.bug_report_outlined),
    );
  }

  static Future<void> debug(BuildContext context) async {}
}
