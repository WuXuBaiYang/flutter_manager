import 'package:flutter/material.dart';
import 'package:flutter_manager/model/theme_scheme.dart';
import 'package:flutter_manager/widget/scheme_item.dart';

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

  // 展示对话框
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
  // 网格代理
  final _gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 45,
    crossAxisSpacing: 14,
    mainAxisSpacing: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 240),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: _gridDelegate,
            itemCount: widget.schemes.length,
            padding: const EdgeInsets.all(14),
            itemBuilder: (_, index) {
              final item = widget.schemes[index];
              return _buildThemeSchemeItem(item);
            },
          ),
        ),
      ),
    );
  }

  // 构建主题配色项
  Widget _buildThemeSchemeItem(ThemeSchemeModel item) {
    return IconButton.outlined(
      tooltip: item.label,
      icon: ThemeSchemeItem(item: item),
      onPressed: () => Navigator.of(context).pop(item),
    );
  }
}
