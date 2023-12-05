import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/color_item.dart';
import 'package:flutter_manager/widget/dialog/color_picker.dart';

/*
* 颜色选择表单项
* @author wuxubaiyang
* @Time 2023/12/4 19:50
*/
class ColorPickerFormField extends StatelessWidget {
  // 表单项key
  final Key? fieldKey;

  // 初始化值
  final Color? initialValue;

  // 保存回调
  final FormFieldSetter<Color>? onSaved;

  // 颜色示例大小
  final double size;

  const ColorPickerFormField({
    super.key,
    this.onSaved,
    this.fieldKey,
    this.size = 30,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<Color>(
      key: fieldKey,
      onSaved: onSaved,
      initialValue: initialValue,
      builder: (field) {
        return _buildFormField(context, field);
      },
    );
  }

  // 构建表单字段
  Widget _buildFormField(BuildContext context, FormFieldState<Color> field) {
    final inputDecoration = InputDecoration(
      border: InputBorder.none,
      errorText: field.errorText,
      contentPadding: EdgeInsets.zero,
    );
    final color = field.value ?? Colors.transparent;
    return InputDecorator(
      decoration: inputDecoration,
      child: ListTile(
        title: const Text('颜色'),
        onTap: () => _showColorPicker(context, field),
        contentPadding: const EdgeInsets.only(right: 4),
        trailing: ColorPickerItem(
          size: size,
          color: color,
          isSelected: true,
          onPressed: () => _showColorPicker(context, field),
        ),
      ),
    );
  }

  // 展示颜色选择器
  Future<void> _showColorPicker(
      BuildContext context, FormFieldState<Color> field) async {
    final result = await ColorPickerDialog.show(
      context,
      current: field.value,
      useTransparent: true,
      colors: Colors.primaries,
    );
    if (result != null) field.didChange(result);
  }
}
