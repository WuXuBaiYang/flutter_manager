import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/permission_picker.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';
import 'platform_item.dart';
import 'provider.dart';

/*
* 项目平台permission项组件
* @author wuxubaiyang
* @Time 2023/12/8 9:55
*/
class PermissionPlatformItem extends StatelessWidget {
  // 平台
  final PlatformType platform;

  // 权限列表
  final List<PlatformPermission> permissions;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const PermissionPlatformItem({
    super.key,
    required this.platform,
    required this.permissions,
    this.crossAxisCellCount = 3,
    this.mainAxisExtent = 280,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      title: '权限管理（${permissions.length}）',
      actions: [
        _buildAddPermissionButton(context),
      ],
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: permissions.isNotEmpty
          ? range(80 * permissions.length + 40, 140, 500)
          : 220,
      content: EmptyBoxView(
        hint: '暂无权限信息',
        isEmpty: permissions.isEmpty,
        child: _buildPermissionList(context),
      ),
    );
  }

  // 构建添加权限按钮
  Widget _buildAddPermissionButton(BuildContext context) {
    final provider = context.read<PlatformProvider>();
    return IconButton(
      iconSize: 20,
      icon: const Icon(Icons.add),
      onPressed: () async {
        final result = await showPermissionPicker(
          context,
          platform: platform,
          permissions: permissions,
        );
        if (!context.mounted) return;
        provider.updatePermission(platform, result).loading(context);
      },
    );
  }

  // 恢复滚动控制器
  ScrollController _restoreScrollController(BuildContext context) {
    final cacheKey = 'permission_offset_$platform';
    final provider = context.read<PlatformProvider>();
    final offset = provider.restoreCache<double>(cacheKey) ?? 0.0;
    final controller = ScrollController(initialScrollOffset: offset);
    controller.addListener(
        () => provider.cache<dynamic>(cacheKey, controller.offset));
    return controller;
  }

  // 构建权限列表
  Widget _buildPermissionList(BuildContext context) {
    final provider = context.read<PlatformProvider>();
    return ListView.separated(
      itemCount: permissions.length,
      separatorBuilder: (_, i) => const Divider(),
      controller: _restoreScrollController(context),
      itemBuilder: (_, i) {
        final item = permissions[i];
        return Dismissible(
          key: ObjectKey(item),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => provider
              .updatePermission(
                platform,
                permissions.where((e) => e != item).toList(),
              )
              .loading(context),
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 14),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _buildItem(context, item),
        );
      },
    );
  }

  // 构建默认权限列表项
  Widget _buildItem(BuildContext context, PlatformPermission item) {
    final textStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey);
    final isThreeLine = [PlatformType.ios].contains(platform);
    return ListTile(
      isThreeLine: isThreeLine,
      contentPadding: EdgeInsets.zero,
      title: Text(item.name, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(item.desc, style: textStyle),
          if (isThreeLine) _buildItemInput(context, item),
        ],
      ),
    );
  }

  // 恢复input控制器
  TextEditingController _restoreInputController(
      BuildContext context, PlatformPermission item) {
    final cacheKey = 'permission_input_${platform}_${item.value}';
    final provider = context.read<PlatformProvider>();
    final controller = provider.restoreCache<TextEditingController>(cacheKey) ??
        TextEditingController(text: item.input)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: item.input.length),
      );
    return provider.cache(cacheKey, controller);
  }

  // 构建权限输入
  Widget _buildItemInput(BuildContext context, PlatformPermission item) {
    final controller = _restoreInputController(context, item);
    final provider = context.read<PlatformProvider>();
    updateInput() {
      if (controller.text == item.input) return;
      if (!permissions.remove(item)) return;
      permissions.add(item.copyWith(
        input: controller.text,
      ));
      provider
          .updatePermission(platform, permissions)
          .loading(context, dismissible: false);
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.runtimeType != KeyDownEvent) return;
        if (event.logicalKey.keyId != LogicalKeyboardKey.enter.keyId) return;
        updateInput();
      },
      child: StatefulBuilder(builder: (_, setState) {
        final isEditing = controller.text != item.input;
        return TextFormField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '权限用途描述',
            suffixIcon: AnimatedOpacity(
              opacity: isEditing ? 1 : 0,
              duration: const Duration(milliseconds: 80),
              child: IconButton(
                iconSize: 18,
                onPressed: updateInput,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.done),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        );
      }),
    );
  }
}
