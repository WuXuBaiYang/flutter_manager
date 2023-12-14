import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // label
  final String label;

  // 选择器
  final FormFieldValidator<String>? validator;

  const LabelPlatformItem({
    super.key,
    required this.platform,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: ProjectPlatformItem(
        title: '项目名',
        mainAxisExtent: 110,
        crossAxisCellCount: 3,
        content: _buildLabelItem(context, formKey),
      ),
    );
  }

  // 恢复label控制器
  TextEditingController _restoreLabelController(BuildContext context) {
    final cacheKey = 'label_$platform';
    final provider = context.read<PlatformProvider>();
    final controller = provider.restoreCache<TextEditingController>(cacheKey) ??
        TextEditingController(text: label)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: label.length),
      );
    return provider.cache(cacheKey, controller);
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context, GlobalKey<FormState> formKey) {
    final provider = context.watch<PlatformProvider>();
    final controller = _restoreLabelController(context);
    updateLabel() {
      final currentState = formKey.currentState;
      if (currentState == null || !currentState.validate()) return;
      provider
          .updateLabel(platform, controller.text)
          .loading(context, dismissible: false);
    }

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.runtimeType != RawKeyDownEvent) return;
        if (event.logicalKey.keyId != LogicalKeyboardKey.enter.keyId) return;
        updateLabel();
      },
      child: StatefulBuilder(builder: (_, setState) {
        final isEditing = controller.text != label;
        return TextFormField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: '请输入项目名',
            suffixIcon: AnimatedOpacity(
              opacity: isEditing ? 1 : 0,
              duration: const Duration(milliseconds: 80),
              child: IconButton(
                iconSize: 18,
                onPressed: updateLabel,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.done),
                visualDensity: VisualDensity.compact,
              ),
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
