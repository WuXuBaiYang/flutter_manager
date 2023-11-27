import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/color_item.dart';
import 'package:provider/provider.dart';

/*
* 颜色选择对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class ColorPickerDialog extends StatefulWidget {
  // 色值列表
  final List<Color> colors;

  // 当前颜色
  final Color? current;

  // 是否使用透明
  final bool useTransparent;

  const ColorPickerDialog({
    super.key,
    required this.colors,
    this.current,
    this.useTransparent = false,
  });

  // 展示弹窗
  static Future<Color?> show(
    BuildContext context, {
    required List<Color> colors,
    bool useTransparent = false,
    Color? current,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        colors: colors,
        current: current,
        useTransparent: useTransparent,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ColorPickerDialogState();
}

/*
* 颜色选择对话框-状态
* @author wuxubaiyang
* @Time 2023/11/25 19:39
*/
class _ColorPickerDialogState extends State<ColorPickerDialog> {
  @override
  Widget build(BuildContext context) {
    Colors.transparent;
    return AlertDialog(
      scrollable: true,
      title: const Text('选择颜色'),
      content: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          ...widget.colors.map((item) {
            return ColorPickerItem(
              color: item,
              isSelected: item == widget.current,
              onPressed: () => Navigator.pop(context, item),
            );
          }),
          if (widget.useTransparent) _buildTransparent(context),
        ],
      ),
    );
  }

  // 构建透明色块
  Widget _buildTransparent(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final splashColor = provider.getSplashColor(context);
    final opacity = provider.isDark(context) ? 0.05 : 0.2;
    return ColorPickerItem(
      isSelected: widget.current == Colors.transparent,
      onPressed: () => Navigator.pop(context, Colors.transparent),
      color: splashColor.withOpacity(opacity),
    );
  }
}
