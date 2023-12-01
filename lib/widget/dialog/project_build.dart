import 'package:flutter/material.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';

/*
* 项目构建弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectBuildDialog extends StatefulWidget {
  // 项目信息
  final Project project;

  const ProjectBuildDialog({super.key, required this.project});

  // 展示弹窗
  static Future<void> show(BuildContext context,
      {required Project project}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectBuildDialog(
        project: project,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ProjectBuildDialogState();
}

/*
* 项目构建弹窗状态
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class _ProjectBuildDialogState extends State<ProjectBuildDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('打包'),
      content: ConstrainedBox(
        constraints: BoxConstraints.tight(const Size.square(200)),
        child: const EmptyBoxView(
          isEmpty: true,
          hint: '功能施工中',
          iconData: Icons.build,
          child: SizedBox(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        const TextButton(
          onPressed: null,
          child: Text('确定'),
        ),
      ],
    );
  }
}
