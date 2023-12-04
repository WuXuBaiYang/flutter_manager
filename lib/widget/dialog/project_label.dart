import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';

/*
* 项目修改别名弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLabelDialog extends StatelessWidget {
  // 平台与label对照表
  final Map<PlatformType, String?> platformLabelMap;

  const ProjectLabelDialog({super.key, required this.platformLabelMap});

  // 展示弹窗
  static Future<Map<PlatformType, String>?> show(BuildContext context,
      {required Map<PlatformType, String?> platformLabelMap}) async {
    return showDialog<Map<PlatformType, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectLabelDialog(
        platformLabelMap: platformLabelMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: const Text('别名'),
      constraints: BoxConstraints.tight(const Size.square(200)),
      content: _buildContent(context),
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
