import 'package:flutter/material.dart';

/*
* 空盒子
* @author wuxubaiyang
* @Time 2023/11/28 15:13
*/
class EmptyBoxView extends StatelessWidget {
  // 子元素
  final Widget? child;

  // 是否为空
  final bool isEmpty;

  // 提示
  final String hint;

  // 自定义颜色
  final Color? color;

  // 空图片尺寸
  final double placeholderSize;

  // 动画时长
  final Duration duration;

  // 自定义图标
  final IconData? iconData;

  // 自定义子元素（与iconData互斥）
  final Widget? icon;

  const EmptyBoxView({
    super.key,
    required this.isEmpty,
    this.icon,
    this.child,
    this.color,
    this.iconData,
    this.hint = '',
    this.placeholderSize = 100,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) {
    final crossFadeState =
        isEmpty ? CrossFadeState.showSecond : CrossFadeState.showFirst;
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: crossFadeState,
      firstChild: child ?? const SizedBox(),
      secondChild: _buildPlaceholder(context),
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(key: bottomChildKey, child: bottomChild),
            Positioned.fill(key: topChildKey, child: topChild),
          ],
        );
      },
    );
  }

  // 构建空白占位图
  Widget _buildPlaceholder(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final color = this.color ?? titleStyle?.color?.withOpacity(0.1);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ??
              Icon(
                color: color,
                size: placeholderSize,
                iconData ?? Icons.inbox,
              ),
          const SizedBox(height: 14),
          Text(hint,
              textAlign: TextAlign.center,
              style: titleStyle?.copyWith(color: color)),
        ],
      ),
    );
  }
}
