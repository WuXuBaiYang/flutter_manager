import 'package:flutter/material.dart';
import 'package:flutter_manager/model/theme_scheme.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/scheme_item.dart';

/*
* 主题配色对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class ThemeSchemeDialog extends StatefulWidget {
  // 主题配色方案列表
  final List<ThemeSchemeModel> schemes;

  // 当前主题配色方案
  final ThemeSchemeModel? current;

  const ThemeSchemeDialog({
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
      builder: (context) => ThemeSchemeDialog(
        schemes: schemes,
        current: current,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ThemeSchemeDialogState();
}

/*
* 主题配色对话框-状态
* @author wuxubaiyang
* @Time 2023/11/25 19:39
*/
class _ThemeSchemeDialogState extends State<ThemeSchemeDialog> {
  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      title: const Text('选择主题配色'),
      content: _buildContent(),
    );
  }

  // 构建内容
  Widget _buildContent() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: widget.schemes.map((item) {
        return ThemeSchemeItem(
          scheme: item,
          isSelected: item == widget.current,
          onPressed: () => Navigator.pop(context, item),
        );
      }).toList(),
    );
  }
}
