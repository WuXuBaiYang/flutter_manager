import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示项目构建弹窗
Future<void> showProjectBuild(BuildContext context,
    {required Project project}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectBuildDialog(
      project: project,
    ),
  );
}

/*
* 项目构建弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectBuildDialog extends ProviderView<ProjectBuildDialogProvider> {
  // 项目信息
  final Project project;

  ProjectBuildDialog({super.key, required this.project});

  @override
  ProjectBuildDialogProvider? createProvider(BuildContext context) =>
      ProjectBuildDialogProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('打包'),
      content: _buildContent(context),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {},
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return const EmptyBoxView(
      isEmpty: true,
      hint: '功能施工中',
      iconData: Icons.build,
      child: SizedBox(),
    );
  }
}

class ProjectBuildDialogProvider extends BaseProvider {
  ProjectBuildDialogProvider(super.context);
}
