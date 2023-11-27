import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/environment.dart';

/*
* 本地路径文本输入框组件
* @author wuxubaiyang
* @Time 2023/11/27 10:58
*/
class LocalPathTextFormField extends StatelessWidget {
  // 输入框控制器
  final TextEditingController controller;

  // 标签
  final String label;

  // 提示
  final String hint;

  // 检查是否有效
  final bool checkAvailable;

  const LocalPathTextFormField({
    super.key,
    required this.controller,
    this.hint = '',
    this.label = '',
    this.checkAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return '路径不能为空';
        }
        if (checkAvailable && !EnvironmentTool.isPathAvailable(v)) {
          return '路径不可用';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        suffixIcon: IconButton(
          onPressed: _importLocalPath,
          icon: const Icon(Icons.folder),
        ),
      ),
    );
  }

  // 导入本地路径
  Future<void> _importLocalPath() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: label,
      lockParentWindow: true,
      initialDirectory: controller.text,
    );
    if (dir == null) return;
    controller.text = dir;
  }
}
