import 'package:flutter/material.dart';
import 'package:flutter_manager/model/theme_scheme.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/scheme_item.dart';

/*
* 主题配色对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class SchemePickerDialog extends StatelessWidget {
  // 主题配色方案列表
  final List<ThemeSchemeModel> schemes;

  // 当前主题配色方案
  final ThemeSchemeModel? current;

  const SchemePickerDialog({
    super.key,
    required this.schemes,
    this.current,
  });

  // 展示弹窗
  static Future<ThemeSchemeModel?> show(
    BuildContext context, {
    required List<ThemeSchemeModel> schemes,
    ThemeSchemeModel? current,
  }) {
    return showDialog<ThemeSchemeModel>(
      context: context,
      builder: (context) => SchemePickerDialog(
        schemes: schemes,
        current: current,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      title: const Text('选择主题配色'),
      content: _buildContent(context),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: schemes.map((item) {
        return ThemeSchemeItem(
          scheme: item,
          isSelected: item == current,
          onPressed: () => Navigator.pop(context, item),
        );
      }).toList(),
    );
  }
}
