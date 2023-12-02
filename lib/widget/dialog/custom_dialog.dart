import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* 自定义弹窗
* @author wuxubaiyang
* @Time 2023/12/2 20:28
*/
class CustomDialog extends StatelessWidget {
  // provider集合
  final List<SingleChildWidget> providers;

  // 是否可滚动
  final bool scrollable;

  // 标题
  final Widget? title;

  // 内容
  final WidgetBuilder builder;

  // 动作按钮集合
  final List<Widget>? actions;

  // 约束
  final BoxConstraints constraints;

  const CustomDialog({
    super.key,
    required this.builder,
    this.title,
    this.actions,
    this.scrollable = false,
    this.providers = const [],
    this.constraints = const BoxConstraints(maxHeight: 300),
  });

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return _buildDialog(context);
    return MultiProvider(
      providers: providers,
      builder: (context, _) {
        return _buildDialog(context);
      },
    );
  }

  // 构建弹窗内容
  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      title: title,
      scrollable: scrollable,
      content: ConstrainedBox(
        constraints: constraints,
        child: builder(context),
      ),
      actions: actions,
    );
  }
}
