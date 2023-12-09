import 'package:flutter/material.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:provider/provider.dart';
import 'platform_item.dart';

/*
* 项目平台label组件项
* @author wuxubaiyang
* @Time 2023/12/8 9:24
*/
class LabelPlatformItem extends StatelessWidget {
  // 当前平台
  final PlatformType platform;

  // 项目信息
  final Project? project;

  // label
  final String label;

  // 提交回调
  final ValueChanged<String>? onSubmitted;

  // 选择器
  final FormFieldValidator<String>? validator;

  const LabelPlatformItem({
    super.key,
    required this.platform,
    required this.label,
    this.project,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ProjectPlatformItemController();
    final textController = TextEditingController(text: label);
    return ProjectPlatformItem.extent(
      mainAxisExtent: 140,
      crossAxisCellCount: 3,
      controller: controller,
      onReset: () {
        controller.edit(false);
        textController.text = label;
      },
      onSubmitted: () => _submitLabel(context, textController.text),
      content: _buildLabelItem(context, controller, textController),
    );
  }

  // 构建标签项
  Widget _buildLabelItem(
    BuildContext context,
    ProjectPlatformItemController controller,
    TextEditingController textController,
  ) {
    return TextFormField(
      controller: textController,
      onChanged: (v) => controller.edit(v != label),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        labelText: '项目名',
        hintText: '请输入项目名',
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return '请输入项目名';
        }
        return validator?.call(value);
      },
    );
  }

  // 提交label
  void _submitLabel(BuildContext context, String label) {
    if (project == null) return onSubmitted?.call(label);
    context
        .read<PlatformProvider>()
        .updateLabel(platform, project!.path, label)
        .loading(context)
        .then((_) => null)
        .catchError((e) {
      SnackTool.showMessage(context, message: '修改失败：${e.toString()}');
    });
  }
}
