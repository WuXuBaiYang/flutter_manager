import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/color_item.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示颜色选择弹窗
Future<Color?> showColorPicker(
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

/*
* 颜色选择对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class ColorPickerDialog extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      title: const Text('选择颜色'),
      content: _buildContent(context),
      style: CustomDialogStyle(
        constraints: const BoxConstraints.tightFor(width: 340),
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        ...colors.map((item) {
          return ColorPickerItem(
            color: item,
            isSelected: item == current,
            onPressed: () => Navigator.pop(context, item),
          );
        }),
        if (useTransparent) _buildTransparent(context),
      ],
    );
  }

  // 构建透明色块
  Widget _buildTransparent(BuildContext context) {
    final opacity =
        Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.2;
    return ColorPickerItem(
      isSelected: current == Colors.transparent,
      color: Theme.of(context).splashColor.withValues(alpha: opacity),
      onPressed: () => Navigator.pop(context, Colors.transparent),
    );
  }
}
