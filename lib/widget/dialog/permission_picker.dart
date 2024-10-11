import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示权限选择弹窗
Future<List<PlatformPermission>?> showPermissionPicker(
  BuildContext context, {
  required PlatformType platform,
  List<PlatformPermission>? permissions,
}) {
  return showDialog<List<PlatformPermission>>(
    context: context,
    builder: (context) => PermissionPickerDialog(
      platform: platform,
      permissions: permissions,
    ),
  );
}

/*
* 权限选择列表弹窗
* @author wuxubaiyang
* @Time 2023/11/25 19:38
*/
class PermissionPickerDialog extends ProviderView {
  // 所选平台
  final PlatformType platform;

  // 已选权限集合
  final List<PlatformPermission>? permissions;

  PermissionPickerDialog({
    super.key,
    required this.platform,
    this.permissions,
  });

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<PermissionPickerDialogProvider>(
          create: (context) => PermissionPickerDialogProvider(context,
              permissions: permissions ?? []),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final provider = context.read<PermissionPickerDialogProvider>();
    return CustomDialog(
      content: _buildContent(context),
      title: Selector<PermissionPickerDialogProvider, int>(
        selector: (_, provider) => provider.selectPermissions.length,
        builder: (_, count, __) {
          return Text('${platform.name}权限（$count）');
        },
      ),
      constraints: const BoxConstraints.tightFor(width: 340),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () => Navigator.pop(context, provider.selectPermissions),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final controller = TextEditingController();
    final provider = context.read<PermissionPickerDialogProvider>();
    return FutureProvider<List<PlatformPermission>?>(
      initialData: null,
      create: (_) => ProjectTool.getFullPermissions(platform),
      builder: (context, __) {
        final permissions = context.watch<List<PlatformPermission>?>() ?? [];
        final status =
            permissions.isEmpty ? LoadStatus.loading : LoadStatus.success;
        return LoadingStatus(
          status: status,
          builder: (_, __) {
            return StatefulBuilder(
              builder: (_, setState) {
                final temp = controller.text.isNotEmpty
                    ? permissions
                        .where((e) => e.search(controller.text))
                        .toList()
                    : permissions;
                return Selector<PermissionPickerDialogProvider,
                    List<PlatformPermission>>(
                  selector: (_, provider) => provider.selectPermissions,
                  builder: (_, selectPermissions, __) {
                    final checked = (temp.length != selectPermissions.length)
                        ? (selectPermissions.isEmpty ? false : null)
                        : true;
                    return Column(children: [
                      CheckboxListTile(
                        value: checked,
                        tristate: true,
                        title: SearchBar(
                          hintText: '输入过滤条件',
                          controller: controller,
                          onChanged: (v) => setState(() {}),
                        ),
                        onChanged: (v) => provider.selectPermissions =
                            !(checked ?? false) ? permissions : [],
                      ),
                      Expanded(
                        child: _buildPermissionList(
                            context, temp, selectPermissions),
                      ),
                    ]);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // 构建权限列表
  Widget _buildPermissionList(
    BuildContext context,
    List<PlatformPermission> permissions,
    List<PlatformPermission> selectPermissions,
  ) {
    final provider = context.read<PermissionPickerDialogProvider>();
    return ListView.separated(
      shrinkWrap: true,
      itemCount: permissions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final item = permissions[i];
        return CheckboxListTile(
          value: selectPermissions.contains(item),
          onChanged: (_) => provider.selectPermission(item),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
  }
}

/*
* 权限选择列表弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/14 9:38
*/
class PermissionPickerDialogProvider extends BaseProvider {
  // 已选权限集合
  List<PlatformPermission> _selectPermissions;

  // 获取已选权限集合
  List<PlatformPermission> get selectPermissions => _selectPermissions;

  // 设置已选权限集合
  set selectPermissions(List<PlatformPermission> value) {
    _selectPermissions = value;
    notifyListeners();
  }

  PermissionPickerDialogProvider(super.context,
      {required List<PlatformPermission> permissions})
      : _selectPermissions = permissions;

  // 选择权限
  void selectPermission(PlatformPermission permission) {
    _selectPermissions = [
      if (!selectPermissions.contains(permission)) permission,
      ...selectPermissions.where((e) => e != permission),
    ];
    notifyListeners();
  }
}
