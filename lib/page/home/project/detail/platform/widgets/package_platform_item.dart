import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:jtech_base/jtech_base.dart';
import 'platform_item.dart';
import 'provider.dart';

/*
* 项目平台package组件项
* @author wuxubaiyang
* @Time 2023/12/8 9:24
*/
class PackagePlatformItem extends StatelessWidget {
  // 当前平台
  final PlatformType platform;

  // package
  final String package;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  // 选择器
  final FormFieldValidator<String>? validator;

  const PackagePlatformItem({
    super.key,
    required this.platform,
    required this.package,
    this.validator,
    this.mainAxisExtent = 110,
    this.crossAxisCellCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: ProjectPlatformItem(
        title: '包名',
        mainAxisExtent: mainAxisExtent,
        crossAxisCellCount: crossAxisCellCount,
        content: _buildPackageItem(context, formKey),
      ),
    );
  }

  // 恢复package控制器
  TextEditingController _restorePackageController(BuildContext context) {
    final cacheKey = 'package_$platform';
    final provider = context.read<PlatformProvider>();
    final controller = provider.restoreCache<TextEditingController>(cacheKey) ??
        TextEditingController(text: package)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: package.length),
      );
    return provider.cache(cacheKey, controller);
  }

  // 构建包名项
  Widget _buildPackageItem(BuildContext context, GlobalKey<FormState> formKey) {
    final controller = _restorePackageController(context);
    updatePackage() {
      final currentState = formKey.currentState;
      if (currentState == null || !currentState.validate()) return;
      context
          .read<PlatformProvider>()
          .updatePackage(platform, controller.text)
          .loading(context, dismissible: false);
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.runtimeType != KeyDownEvent) return;
        if (event.logicalKey.keyId != LogicalKeyboardKey.enter.keyId) return;
        updatePackage();
      },
      child: StatefulBuilder(builder: (_, setState) {
        final isEditing = controller.text != package;
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
                onPressed: updatePackage,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.done),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return '请输入包名';
            }
            final regExp = RegExp(
              r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)*$',
            );
            if (!regExp.hasMatch(value!)) {
              return '包名格式不正确';
            }
            return validator?.call(value);
          },
        );
      }),
    );
  }
}
