import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/scheme_item.dart';

// 展示主题配色弹窗
Future<ThemeSchemeTuple?> showSchemePicker(
  BuildContext context, {
  required List<ThemeSchemeTuple> themeSchemes,
  ThemeSchemeTuple? current,
}) {
  return showDialog<ThemeSchemeTuple>(
    context: context,
    builder: (context) => SchemePickerDialog(
      themeSchemes: themeSchemes,
      current: current,
    ),
  );
}

/*
* 主题配色对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class SchemePickerDialog extends StatelessWidget {
  // 主题配色方案列表
  final List<ThemeSchemeTuple> themeSchemes;

  // 当前主题配色方案
  final ThemeSchemeTuple? current;

  const SchemePickerDialog({
    super.key,
    required this.themeSchemes,
    this.current,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      title: const Text('选择主题配色'),
      content: _buildContent(context),
      constraints: const BoxConstraints.tightFor(width: 340),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: themeSchemes
          .map((item) => ThemeSchemeItem(
                themeScheme: item,
                isSelected: item.scheme == current?.scheme,
                onPressed: () => Navigator.pop(context, item),
              ))
          .toList(),
    );
  }
}
