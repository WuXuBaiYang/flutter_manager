import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';

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
class ProjectBuildDialog extends StatelessWidget {
  // 项目信息
  final Project project;

  const ProjectBuildDialog({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: const Text('打包'),
      content: _buildContent(context),
      constraints: BoxConstraints.tight(const Size.square(200)),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
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
