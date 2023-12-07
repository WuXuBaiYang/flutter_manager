import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';

/*
* 项目字体资源管理
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectFontDialog extends StatelessWidget {
  const ProjectFontDialog({super.key});

  // 展示弹窗
  static Future<dynamic> show(BuildContext context) async {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectFontDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectFontDialogProvider>(
      create: (_) => ProjectFontDialogProvider(),
      builder: (context, _) {
        return CustomDialog(
          title: const Text('字体管理'),
          content: _buildContent(context),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: null,
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return EmptyBoxView(
      hint: '无可用平台',
      isEmpty: true,
      child: const SizedBox(),
    );
  }
}

/*
* 项目字体资源管理数据提供者
* @author wuxubaiyang
* @Time 2023/12/5 14:51
*/
class ProjectFontDialogProvider extends BaseProvider {}
