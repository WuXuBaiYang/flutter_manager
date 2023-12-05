import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/*
* 本地路径文本输入框组件
* @author wuxubaiyang
* @Time 2023/11/27 10:58
*/
class LocalPathTextFormField extends StatelessWidget {
  // 输入框控制器
  final TextEditingController controller;

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

  LocalPathTextFormField({
    super.key,
    this.onSaved,
    this.hint = '',
    this.validator,
    this.label = '',
    this.onPathSelected,
    String? initialValue,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(text: initialValue);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      controller: controller,
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
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: label,
      lockParentWindow: true,
      initialDirectory: controller.text,
    );
    if (dir == null) return;
    controller.text = dir;
    onPathSelected?.call(dir);
  }
}
