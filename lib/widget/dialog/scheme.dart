import 'package:flutter/material.dart';
import 'package:flutter_manager/model/theme_scheme.dart';
import 'package:flutter_manager/provider/theme.dart';
import 'package:flutter_manager/widget/scheme_item.dart';
import 'package:provider/provider.dart';

/*
* 主题配色对话框
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class ThemeSchemeDialog extends StatefulWidget {
  // 主题配色方案列表
  final List<ThemeSchemeModel> schemes;

  const ThemeSchemeDialog({
    super.key,
    required this.schemes,
  });

  // 展示弹窗
  static Future<ThemeSchemeModel?> show(
    BuildContext context, {
    required List<ThemeSchemeModel> schemes,
  }) {
    return showDialog<ThemeSchemeModel>(
      context: context,
      builder: (context) => ThemeSchemeDialog(
        schemes: schemes,
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
    final provider = context.read<ThemeProvider>();
    final current = provider.getThemeSchemeModel(context);
    return AlertDialog(
      scrollable: true,
      title: const Text('选择主题配色'),
      content: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: widget.schemes.map((e) {
          return _buildThemeSchemeItem(e, e == current);
        }).toList(),
      ),
    );
  }

  // 构建主题配色项
  Widget _buildThemeSchemeItem(ThemeSchemeModel item, bool selected) {
    return IconButton.outlined(
      tooltip: item.label,
      isSelected: selected,
      padding: EdgeInsets.zero,
      icon: ThemeSchemeItem(item: item),
      selectedIcon: CircleAvatar(
        radius: 18,
        child: ThemeSchemeItem(item: item),
      ),
      onPressed: () => Navigator.of(context).pop(item),
    );
  }
}
