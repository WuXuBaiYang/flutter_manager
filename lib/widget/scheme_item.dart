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
  final ThemeSchemeModel item;

  // 旋转角度
  final double angle;

  // 大小
  final double size;

  const ThemeSchemeItem({
    super.key,
    required this.item,
    this.size = 24,
    this.angle = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox.fromSize(
        size: Size.square(size),
        child: CustomPaint(
          painter: HalfCirclePainter((
          item.primary,
          item.secondary,
          )),
        ),
      ),
    );
  }
}
