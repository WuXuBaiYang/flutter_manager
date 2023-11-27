import 'package:flutter/material.dart';
import 'log.dart';

/*
* 加载弹窗动画
* @author wuxubaiyang
* @Time 2023/7/19 16:43
*/
class Loading {
  // 加载弹窗dialog缓存
  static Future? _loadingDialog;

  // 展示加载弹窗
  static Future<T?>? show<T>(
    BuildContext context, {
    required Future<T?> loadFuture,
    bool dismissible = true,
    BoxConstraints? constraints,
    Widget? child,
  }) async {
    final navigator = Navigator.of(context);
    final start = DateTime.now();
    const duration = Duration(milliseconds: 300);
    try {
      if (_loadingDialog != null) navigator.maybePop();
      _loadingDialog = showDialog<void>(
        context: context,
        barrierDismissible: dismissible,
        builder: (_) => _buildLoadingView(child, constraints),
      )..whenComplete(() => _loadingDialog = null);
      final result = await loadFuture;
      return result;
    } catch (e) {
      LogTool.e('弹窗请求异常：', error: e);
      rethrow;
    } finally {
      // 如果传入的future加载时间过短（还不够弹窗动画时间），则进行等待
      final end = DateTime.now().subtract(duration);
      if (end.compareTo(start) < 0) await Future.delayed(duration);
      if (_loadingDialog != null) await navigator.maybePop();
    }
  }

  // 构建加载视图
  static Widget _buildLoadingView(Widget? child,
      [BoxConstraints? constraints]) {
    return Center(
      child: Card(
        child: ConstrainedBox(
          constraints: constraints ??
              BoxConstraints.loose(
                const Size.fromWidth(80),
              ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
