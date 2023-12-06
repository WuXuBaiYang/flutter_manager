import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/*
* 本地路径文本输入框组件
* @author wuxubaiyang
* @Time 2023/11/27 10:58
*/
class LocalPathFormField extends StatelessWidget {
  // 表单项key
  final GlobalKey<FormFieldState<String>> fieldKey;

  // 输入框控制器
  final TextEditingController? controller;

  // 验证器
  final FormFieldValidator<String>? validator;

  // 路径选择更新回调
  final ValueChanged<String?>? onPathSelected;

  // 保存回调
  final FormFieldSetter<String>? onSaved;

  // 标签
  final String label;

  // 提示
  final String hint;

  // 初始值
  final String? initialValue;

  LocalPathFormField({
    super.key,
    GlobalKey<FormFieldState<String>>? fieldKey,
    this.onSaved,
    this.hint = '',
    this.validator,
    this.label = '',
    this.onPathSelected,
    this.initialValue,
    this.controller,
  }) : fieldKey = fieldKey ?? GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      onSaved: onSaved,
      controller: controller,
      initialValue: initialValue,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return '路径不能为空';
        }
        return validator?.call(v);
      },
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        suffixIcon: IconButton(
          onPressed: _pickLocalPath,
          icon: const Icon(Icons.folder),
        ),
      ),
    );
  }

  // 选择本地路径
  Future<void> _pickLocalPath() async {
    final initDir = controller?.text ?? fieldKey.currentState?.value;
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: label,
      lockParentWindow: true,
      initialDirectory: initDir,
    );
    if (dir == null) return;
    if (controller != null) {
      controller!.text = dir;
    } else {
      fieldKey.currentState?.didChange(dir);
    }
    onPathSelected?.call(dir);
  }
}
