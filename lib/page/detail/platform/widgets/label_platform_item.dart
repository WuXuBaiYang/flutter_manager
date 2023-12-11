import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/platform/widgets/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
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

  // 选择器
  final FormFieldValidator<String>? validator;

  const LabelPlatformItem({
    super.key,
    required this.platform,
    required this.label,
    this.project,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      title: '项目名',
      mainAxisExtent: 110,
      crossAxisCellCount: 3,
      content: _buildLabelItem(context),
    );
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context) {
    final provider = context.watch<PlatformProvider>();
    final controller = TextEditingController(text: label);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.runtimeType != RawKeyDownEvent) return;
        if (event.logicalKey.keyId != LogicalKeyboardKey.enter.keyId) return;
        if (project == null) return;
        context
            .read<PlatformProvider>()
            .updateLabel(platform, project!.path, controller.text)
            .loading(context, dismissible: false);
      },
      child: StatefulBuilder(builder: (_, setState) {
        final isEditing = controller.text != label;
        return TextFormField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: '请输入项目名',
            suffixIcon: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.done),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                if (!isEditing || project == null) return null;
                return () => provider
                    .updateLabel(platform, project!.path, controller.text)
                    .loading(context, dismissible: false);
              }(),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return '请输入项目名';
            }
            return validator?.call(value);
          },
        );
      }),
    );
  }
}
