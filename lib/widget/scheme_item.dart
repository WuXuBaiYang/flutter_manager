import 'package:flutter/material.dart';
import 'package:flutter_manager/model/theme_scheme.dart';
import 'half_circle.dart';

/*
* 主题配色项
* @author wuxubaiyang
* @Time 2023/11/24 15:36
*/
class ThemeSchemeItem extends StatelessWidget {
  // 主题配色项
  final ThemeSchemeModel scheme;

  // 旋转角度
  final double angle;

  // 大小
  final double size;

  // 内间距
  final EdgeInsetsGeometry padding;

  // 点击事件
  final VoidCallback? onPressed;

  // 是否已选中
  final bool isSelected;

  // 自定义tooltip
  final String? tooltip;

  const ThemeSchemeItem({
    super.key,
    required this.scheme,
    this.tooltip,
    this.size = 45,
    this.onPressed,
    this.angle = 90,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox.fromSize(
        size: Size.square(size),
        child: _buildItem(scheme),
      ),
    );
  }

  // 构建子项
  Widget _buildItem(ThemeSchemeModel item) {
    if (isSelected) {
      return IconButton.outlined(
        padding: padding,
        onPressed: onPressed,
        icon: _buildItemSub(item),
        tooltip: tooltip ?? item.label,
      );
    }
    return IconButton(
      padding: padding,
      onPressed: onPressed,
      icon: _buildItemSub(item),
      tooltip: tooltip ?? item.label,
    );
  }

  // 构建子项sub
  Widget _buildItemSub(ThemeSchemeModel item) {
    return CustomPaint(
      size: Size.infinite,
      painter: HalfCirclePainter((
        item.primary,
        item.secondary,
      )),
    );
  }
}
