import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/loading.dart';
import 'package:provider/provider.dart';

/*
* 权限选择列表弹窗
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class PermissionPickerDialog extends StatelessWidget {
  // 所选平台
  final PlatformType platform;

  // 已选权限集合
  final List<PlatformPermissionTuple>? permissions;

  const PermissionPickerDialog({
    super.key,
    required this.platform,
    this.permissions,
  });

  // 展示弹窗
  static Future<List<PlatformPermissionTuple>?> show(
    BuildContext context, {
    required PlatformType platform,
    List<PlatformPermissionTuple>? permissions,
  }) {
    return showDialog<List<PlatformPermissionTuple>>(
      context: context,
      builder: (context) => PermissionPickerDialog(
        platform: platform,
        permissions: permissions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PermissionPickerDialogProvider(context,
          permissions: permissions ?? []),
      builder: (context, __) {
        final provider = context.read<PermissionPickerDialogProvider>();
        return CustomDialog(
          content: _buildContent(context),
          title: Text('${platform.name}权限'),
          constraints: const BoxConstraints.tightFor(width: 340),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () =>
                  Navigator.pop(context, provider.selectPermissions),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final controller = TextEditingController();
    return FutureProvider<List<PlatformPermissionTuple>?>(
      initialData: null,
      create: (_) => ProjectTool.getFullPermissions(platform),
      builder: (context, __) {
        final permissions =
            context.watch<List<PlatformPermissionTuple>?>() ?? [];
        return LoadingView(
          loading: permissions.isEmpty,
          builder: (_) {
            return StatefulBuilder(
              builder: (_, setState) {
                final temp = controller.text.isNotEmpty
                    ? permissions
                        .where((e) => e.search(controller.text))
                        .toList()
                    : permissions;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SearchBar(
                      hintText: '输入过滤条件',
                      controller: controller,
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  Expanded(child: _buildPermissionList(context, temp)),
                ]);
              },
            );
          },
        );
      },
    );
  }

  // 构建权限列表
  Widget _buildPermissionList(
      BuildContext context, List<PlatformPermissionTuple> permissions) {
    final provider = context.read<PermissionPickerDialogProvider>();
    return Selector<PermissionPickerDialogProvider,
        List<PlatformPermissionTuple>>(
      selector: (_, provider) => provider.selectPermissions,
      builder: (_, selectPermissions, __) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: permissions.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final item = permissions[i];
            return CheckboxListTile(
              value: selectPermissions.contains(item),
              onChanged: (_) => provider.selectPermission(item),
              title:
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                item.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}

class PermissionPickerDialogProvider extends BaseProvider {
  // 已选权限集合
  List<PlatformPermissionTuple> _selectPermissions;

  // 获取已选权限集合
  List<PlatformPermissionTuple> get selectPermissions => _selectPermissions;

  PermissionPickerDialogProvider(super.context,
      {required List<PlatformPermissionTuple> permissions})
      : _selectPermissions = permissions;

  // 选择权限
  void selectPermission(PlatformPermissionTuple permission) {
    _selectPermissions = [
      if (!selectPermissions.contains(permission)) permission,
      ...selectPermissions.where((e) => e != permission),
    ];
    notifyListeners();
  }
}
