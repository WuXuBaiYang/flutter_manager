import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';

/*
* 项目修改图标弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLogoDialog extends StatelessWidget {
  // 平台与图标表
  final Map<PlatformType, List<PlatformLogoTuple>?> platformLogoMap;

  const ProjectLogoDialog({super.key, required this.platformLogoMap});

  // 展示弹窗
  static Future<Map<PlatformType, String>?> show(BuildContext context,
      {required Map<PlatformType, List<PlatformLogoTuple>?>
          platformLogoMap}) async {
    return showDialog<Map<PlatformType, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectLogoDialog(
        platformLogoMap: platformLogoMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: const Text('图标'),
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
    return ExpansionPanelList.radio(

    );
  }
}
