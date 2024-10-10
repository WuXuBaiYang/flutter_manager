import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示asset资源管理弹窗
Future<dynamic> showProjectAsset(BuildContext context) async {
  return showDialog<dynamic>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const ProjectAssetDialog(),
  );
}

/*
* 项目asset资源管理
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectAssetDialog extends StatelessWidget {
  const ProjectAssetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectAssetDialogProvider>(
      create: (_) => ProjectAssetDialogProvider(context),
      builder: (context, _) {
        return CustomDialog(
          title: const Text('Asset管理'),
          content: _buildContent(context),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const TextButton(
              onPressed: null,
              child: Text('确定'),
            ),
          ],
        );
      },
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
* 项目asset资源管理数据提供者
* @author wuxubaiyang
* @Time 2023/12/5 14:51
*/
class ProjectAssetDialogProvider extends BaseProvider {
  ProjectAssetDialogProvider(super.context);
}
