import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示项目权限选择弹窗
Future<List<PlatformPermission>?> showProjectPermission(
  BuildContext context, {
  required PlatformType platform,
  List<PlatformPermission> permissions = const [],
}) {
  return showDialog<List<PlatformPermission>>(
    context: context,
    builder: (context) => ProjectPermissionDialog(
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
class ProjectPermissionDialog
    extends ProviderView<ProjectPermissionDialogProvider> {
  // 所选平台
  final PlatformType platform;

  // 已选权限集合
  final List<PlatformPermission> permissions;

  ProjectPermissionDialog(
      {super.key, required this.platform, this.permissions = const []});

  @override
  ProjectPermissionDialogProvider? createProvider(BuildContext context) =>
      ProjectPermissionDialogProvider(context, permissions);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: _buildTitle(context),
      content: _buildContent(context),
      style: CustomDialogStyle(
        constraints: const BoxConstraints.tightFor(width: 340),
      ),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () => context.pop(provider.selectPermissions),
        ),
      ],
    );
  }

  // 构建标题
  Widget _buildTitle(BuildContext context) {
    return createSelector<int>(
      selector: (_, provider) => provider.selectPermissions.length,
      builder: (_, count, _) {
        return Text('${platform.name}权限（$count）');
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final searchController = provider.searchController;
    return LoadingFutureBuilder<List<PlatformPermission>?>(
      future: ProjectTool.getFullPermissions(platform),
      builder: (_, permissions, _) {
        if (permissions == null) return const SizedBox();
        return createSelector<List<PlatformPermission>>(
          selector: (_, provider) => provider.selectPermissions,
          builder: (_, selectPermissions, _) {
            return StatefulBuilder(
              builder: (_, setState) {
                final tempList = searchController.text.isNotEmpty
                    ? permissions
                        .where((e) => e.search(searchController.text))
                        .toList()
                    : permissions;
                final checked = (tempList.length != selectPermissions.length)
                    ? (selectPermissions.isEmpty ? false : null)
                    : true;
                return Column(children: [
                  CheckboxListTile(
                    value: checked,
                    tristate: true,
                    title: SearchBar(
                      hintText: '输入过滤条件',
                      controller: searchController,
                      onChanged: (v) => setState(() {}),
                    ),
                    onChanged: (v) => provider.selectPermissions =
                        !(checked ?? false) ? permissions : [],
                  ),
                  Expanded(
                    child: _buildPermissionList(
                      context,
                      tempList,
                      selectPermissions,
                    ),
                  ),
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
    BuildContext context,
    List<PlatformPermission> permissions,
    List<PlatformPermission> selectPermissions,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: permissions.length,
      separatorBuilder: (_, _) => const Divider(),
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
          ),
        );
      },
    );
  }
}

class ProjectPermissionDialogProvider extends BaseProvider {
  // 搜索控制器
  final searchController = TextEditingController();

  ProjectPermissionDialogProvider(super.context, this._selectPermissions);

  // 已选权限集合
  List<PlatformPermission> _selectPermissions;

  // 获取已选权限集合
  List<PlatformPermission> get selectPermissions => _selectPermissions;

  // 设置已选权限集合
  set selectPermissions(List<PlatformPermission> value) {
    _selectPermissions = value;
    notifyListeners();
  }

  // 选择权限
  void selectPermission(PlatformPermission permission) {
    _selectPermissions = [
      if (!selectPermissions.contains(permission)) permission,
      ...selectPermissions.where((e) => e != permission),
    ];
    notifyListeners();
  }
}
