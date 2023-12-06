import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/tool.dart';

/*
* 项目图标表单字段组件
* @author wuxubaiyang
* @Time 2023/12/4 19:31
*/
class ProjectLogoFormField extends StatelessWidget {
  // 持有key
  final Key? fieldKey;

  // 保存回调
  final FormFieldSetter<String>? onSaved;

  // 图标尺寸
  final Size logoSize;

  // 初始值
  final String? initialValue;

  // 圆角
  final BorderRadius borderRadius;

  const ProjectLogoFormField({
    super.key,
    this.onSaved,
    this.fieldKey,
    this.initialValue,
    this.logoSize = const Size.square(55),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: fieldKey,
      onSaved: onSaved,
      initialValue: initialValue,
      validator: (v) {
        if (v?.isEmpty ?? true) {
          return '请选择图标';
        }
        return null;
      },
      builder: (field) {
        return Tooltip(
          message: '选择项目图标',
          child: _buildFormField(context, field),
        );
      },
    );
  }

  // 构建表单字段
  Widget _buildFormField(BuildContext context, FormFieldState<String> field) {
    final logoPath = field.value;
    final inputBorder = logoPath?.isEmpty ?? true
        ? const OutlineInputBorder()
        : InputBorder.none;
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: logoSize.width),
      child: InputDecorator(
        decoration: InputDecoration(
          border: inputBorder,
          errorText: field.errorText,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: SizedBox.fromSize(
          size: logoSize,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => _changeLogoFile(context, field),
            child: _buildFormFieldLogo(logoPath),
          ),
        ),
      ),
    );
  }

  // 切换项目图标
  Future<void> _changeLogoFile(
      BuildContext context, FormFieldState<String> field) async {
    final result = await Tool.pickImageWithEdit(context,
        dialogTitle: '选择项目图标', absoluteRatio: 1.0);
    if (result?.isEmpty ?? true) return;
    field.didChange(result);
    field.validate();
  }

  // 构建表单项图标
  Widget _buildFormFieldLogo(String? logoPath) {
    if (logoPath?.isEmpty ?? true) return const Icon(Icons.add);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.file(
        File(logoPath ?? ''),
        fit: BoxFit.cover,
        width: logoSize.width,
        height: logoSize.height,
      ),
    );
  }
}
