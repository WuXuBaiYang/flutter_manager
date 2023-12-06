import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:provider/provider.dart';

/*
* 图片编辑弹窗
* @author wuxubaiyang
* @Time 2023/12/6 8:48
*/
class ImageEditorDialog extends StatelessWidget {
  // 图片路径
  final String path;

  // 裁剪比例
  final double? ratio;

  const ImageEditorDialog({
    super.key,
    required this.path,
    this.ratio,
  });

  // 展示弹窗
  static Future<String?> show(BuildContext context,
      {required String path, double? ratio}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageEditorDialog(
        path: path,
        ratio: ratio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageEditorDialogProvider(),
      builder: (context, _) {
        return CustomDialog(
          title: const Text('打包'),
          content: _buildContent(context),
          constraints: const BoxConstraints.tightFor(width: 480, height: 350),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('另存为'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<ImageEditorDialogProvider>();
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(8),
            child: ExtendedImage.file(
              File(path),
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: provider.editorKey,
              initEditorConfigHandler: (state) {
                return EditorConfig(
                  cropAspectRatio: ratio,
                  cropLayerPainter: CustomCropLayerPainter(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/*
* 图片编辑弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/6 8:51
*/
class ImageEditorDialogProvider extends BaseProvider {
  // 图片编辑控制key
  final editorKey = GlobalKey<ExtendedImageEditorState>();
}

/*
* 自定义裁剪图层
* @author wuxubaiyang
* @Time 2023/12/6 9:04
*/
class CustomCropLayerPainter extends EditorCropLayerPainter {
}
