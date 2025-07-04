import 'package:flutter/material.dart';

/*
* 选择表单项
* @author wuxubaiyang
* @Time 2023/12/4 19:50
*/
class CheckFormField extends StatelessWidget {
  // 表单项key
  final Key? fieldKey;

  // 初始化值
  final bool? initialValue;

  // 标题
  final String title;

  // 保存回调
  final FormFieldSetter<bool>? onSaved;

  const CheckFormField({
    super.key,
    required this.title,
    this.onSaved,
    this.fieldKey,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      key: fieldKey,
      onSaved: onSaved,
      initialValue: initialValue,
      builder: (field) {
        return _buildFormField(context, field);
      },
    );
  }

  // 构建表单字段
  Widget _buildFormField(BuildContext context, FormFieldState<bool> field) {
    final inputDecoration = InputDecoration(
      border: InputBorder.none,
      errorText: field.errorText,
      contentPadding: EdgeInsets.zero,
    );
    return InputDecorator(
      decoration: inputDecoration,
      child: CheckboxListTile(
        title: Text(title),
        onChanged: field.didChange,
        value: field.value ?? false,
        contentPadding: const EdgeInsets.only(right: 4),
      ),
    );
  }
}
