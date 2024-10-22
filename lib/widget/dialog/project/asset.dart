import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示asset资源管理弹窗
Future<void> showProjectAsset(BuildContext context,
    {required Project project}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectAssetDialog(
      project: project,
    ),
  );
}

/*
* 项目asset资源管理
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectAssetDialog extends ProviderView<ProjectAssetDialogProvider> {
  // 项目信息
  final Project project;

  ProjectAssetDialog({super.key, required this.project});

  @override
  ProjectAssetDialogProvider? createProvider(BuildContext context) =>
      ProjectAssetDialogProvider(context, project);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('Asset管理'),
      content: _buildContent(context),
      decoration: CustomDialogDecoration(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
      ),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        const TextButton(
          onPressed: null,
          child: Text('确定'),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return const EmptyBoxView(
      hint: '无可用平台',
      isEmpty: true,
      child: SizedBox(),
    );
  }
}

class ProjectAssetDialogProvider extends BaseProvider {
  // 项目信息
  final Project project;

  ProjectAssetDialogProvider(super.context, this.project);
}
