import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示字体资源管理弹窗
Future<void> showProjectFont(BuildContext context,
    {required Project project}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectFontDialog(
      project: project,
    ),
  );
}

/*
* 项目字体资源管理
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectFontDialog extends ProviderView<ProjectFontDialogProvider> {
  // 项目信息
  final Project project;

  ProjectFontDialog({super.key, required this.project});

  @override
  ProjectFontDialogProvider? createProvider(BuildContext context) =>
      ProjectFontDialogProvider(context, project);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('字体管理'),
      content: _buildContent(context),
      decoration: CustomDialogDecoration(
        constraints: const BoxConstraints(
          maxWidth: 380,
          maxHeight: 380,
        ),
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

/*
* 项目字体资源管理数据提供者
* @author wuxubaiyang
* @Time 2023/12/5 14:51
*/
class ProjectFontDialogProvider extends BaseProvider {
  // 项目信息
  final Project project;

  ProjectFontDialogProvider(super.context, this.project);
}
