import 'package:flutter/material.dart';

/*
* 空盒子
* @author wuxubaiyang
* @Time 2023/11/28 15:13
*/
class EmptyBoxView extends StatelessWidget {
  // 子元素
  final Widget child;

  // 是否为空
  final bool isEmpty;

  // 提示
  final String hint;

  // 空图片尺寸
  final double placeholderSize;

  const EmptyBoxView({
    super.key,
    required this.child,
    required this.isEmpty,
    this.hint = '',
    this.placeholderSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isEmpty) _buildPlaceholder(context),
      ],
    );
  }

  // 构建空白占位图
  Widget _buildPlaceholder(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final color = titleStyle?.color?.withOpacity(0.1);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox,
            color: color,
            size: placeholderSize,
          ),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: titleStyle?.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
