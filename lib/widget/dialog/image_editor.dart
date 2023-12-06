import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/*
* 图片编辑弹窗
* @author wuxubaiyang
* @Time 2023/12/6 8:48
*/
class ImageEditorDialog extends StatelessWidget {
  // 图片路径
  final String path;

  // 绝对比例（不可编辑）
  final double? absoluteRatio;

  // 初始化裁剪比例
  final double initializeRatio;

  const ImageEditorDialog({
    super.key,
    required this.path,
    this.absoluteRatio,
    this.initializeRatio = 0,
  });

  // 展示弹窗
  static Future<String?> show(BuildContext context,
      {required String path, double? absoluteRatio}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageEditorDialog(
        path: path,
        absoluteRatio: absoluteRatio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageEditorDialogProvider(initializeRatio),
      builder: (context, _) {
        final provider = context.read<ImageEditorDialogProvider>();
        return CustomDialog(
          title: Row(
            children: [
              const Expanded(child: Text('图片裁剪')),
              _buildImageTypeSelector(context),
            ],
          ),
          content: _buildContent(context),
          constraints: const BoxConstraints.tightFor(width: 480, height: 350),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Tool.pickDirectory(dialogTitle: '选择保存路径').then((result) async {
                  if (result?.isEmpty ?? true) return null;
                  return Loading.show(context,
                      loadFuture: provider.saveOtherPath(result!));
                }).then((result) {
                  if (result?.isEmpty ?? true) return;
                  SnackTool.showMessage(context, message: '图片已保存到 $result');
                }).catchError((e) {
                  SnackTool.showMessage(context,
                      message: '图片另存为失败：${e.toString()}');
                });
              },
              child: const Text('另存为'),
            ),
            TextButton(
              onPressed: () {
                Loading.show(context, loadFuture: provider.saveCrop())
                    ?.then((result) {
                  Navigator.pop(context, result);
                }).catchError((e) {
                  SnackTool.showMessage(context,
                      message: '图片裁剪失败：${e.toString()}');
                });
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 构建图片类型选择器
  Widget _buildImageTypeSelector(BuildContext context) {
    final provider = context.read<ImageEditorDialogProvider>();
    return Selector<ImageEditorDialogProvider, CropImageType>(
      selector: (_, provider) => provider._actionTuple.imageType,
      builder: (_, imageType, __) {
        return Row(
          children: [
            if (imageType == CropImageType.ico)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Tooltip(
                  message: '支持最大256边长，将自动输出',
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Tooltip(
              message: '输出图片格式',
              child: DropdownButton<CropImageType>(
                value: imageType,
                icon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.image),
                ),
                onChanged: (v) => provider.updateActions(imageType: v),
                items: CropImageType.values
                    .map((e) => DropdownMenuItem<CropImageType>(
                          value: e,
                          child: Text(' .${e.name}'),
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildImageEditor(context)),
        const SizedBox(height: 14),
        _buildImageEditorActions(context),
      ],
    );
  }

  // 构建图片编辑器
  Widget _buildImageEditor(BuildContext context) {
    final provider = context.read<ImageEditorDialogProvider>();
    return ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Selector<ImageEditorDialogProvider, double>(
          selector: (_, provider) => provider.actionTuple.ratio,
          builder: (_, ratio, __) {
            return ExtendedImage.file(
              File(path),
              cacheRawData: true,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: provider.editorKey,
              initEditorConfigHandler: (_) => EditorConfig(
                cropAspectRatio: absoluteRatio ?? (ratio < 0 ? null : ratio),
              ),
            );
          },
        ));
  }

  // 构建图片编辑器操作
  Widget _buildImageEditorActions(BuildContext context) {
    final ratioDisable = absoluteRatio != null;
    final provider = context.read<ImageEditorDialogProvider>();
    return Selector<ImageEditorDialogProvider, ImageEditorActionTuple>(
      selector: (_, provider) => provider.actionTuple,
      builder: (_, actionTuple, __) {
        return Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 170),
              child: Tooltip(
                message: '圆角',
                child: TextButton.icon(
                  autofocus: true,
                  onPressed: () => provider.updateActions(borderRadius: 0),
                  icon: const Icon(Icons.rounded_corner_rounded),
                  label: Slider(
                    max: 80,
                    label: '${actionTuple.borderRadius}px',
                    value: actionTuple.borderRadius.toDouble(),
                    onChanged: (v) =>
                        provider.updateActions(borderRadius: v.toInt()),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Transform.flip(
              flipX: actionTuple.flip,
              child: IconButton.filled(
                iconSize: 16,
                tooltip: '水平翻转',
                onPressed: provider.changeFlip,
                icon: const Icon(Icons.flip),
                visualDensity: VisualDensity.compact,
              ),
            ),
            Transform.rotate(
              angle: actionTuple.rotate,
              child: IconButton.filled(
                iconSize: 16,
                tooltip: '向左旋转',
                onPressed: () => provider.changeRotate(false),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.rotate_left_rounded),
              ),
            ),
            Transform.rotate(
              angle: actionTuple.rotate,
              child: IconButton.filled(
                iconSize: 16,
                tooltip: '向右旋转',
                onPressed: provider.changeRotate,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.rotate_right_rounded),
              ),
            ),
            if (!ratioDisable)
              Tooltip(
                message: '裁剪比例',
                child: DropdownButton<double>(
                  alignment: Alignment.center,
                  value: absoluteRatio ?? actionTuple.ratio,
                  icon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.aspect_ratio),
                  ),
                  onChanged: !ratioDisable ? provider.changeRatio : null,
                  items: provider.cropAspectRatios.entries
                      .map((e) => DropdownMenuItem<double>(
                    value: e.key,
                    child: Text(e.value),
                  ))
                      .toList(),
                ),
              ),
            IconButton.filledTonal(
              iconSize: 16,
              tooltip: '重置',
              onPressed: provider.reset,
              icon: const Icon(Icons.cleaning_services_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ].expand((e) => [e, const SizedBox(width: 14)]).toList(),
        );
      },
    );
  }
}

// 图片编辑操作项元组
typedef ImageEditorActionTuple = ({
  double ratio,
  bool flip,
  double rotate,
  int borderRadius,
  CropImageType imageType,
});

/*
* 图片编辑弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/6 8:51
*/
class ImageEditorDialogProvider extends BaseProvider {
  // 图片编辑控制key
  final editorKey = GlobalKey<ExtendedImageEditorState>();

  // 图片编辑操作参数元组
  ImageEditorActionTuple _actionTuple = (
    ratio: -1,
    flip: false,
    rotate: 0,
    borderRadius: 0,
    imageType: CropImageType.png,
  );

  // 获取图片编辑操作参数元组
  ImageEditorActionTuple get actionTuple => _actionTuple;

  // 可用裁剪比例集合
  final cropAspectRatios = {
    -1.0: '自定义',
    CropAspectRatios.original: '原始',
    CropAspectRatios.ratio1_1: '1:1',
    CropAspectRatios.ratio4_3: '4:3',
    CropAspectRatios.ratio3_4: '3:4',
    CropAspectRatios.ratio16_9: '16:9',
    CropAspectRatios.ratio9_16: '9:16',
  };

  ImageEditorDialogProvider(double initializeRatio) {
    updateActions(ratio: initializeRatio);
  }

  // 另存为其他路径
  Future<String?> saveOtherPath(String path) =>
      saveCrop(savePath: join(path, genImageFileName()));

  // 保存裁剪后的图片并返回路径
  Future<String?> saveCrop({String? savePath}) async {
    final baseDir = await Tool.getFileCachePath();
    if (baseDir?.isEmpty ?? true) return null;
    final editorState = editorKey.currentState;
    final cropRect = editorState?.getCropRect();
    final editAction = editorState?.editAction;
    if (editorState == null || cropRect == null || editAction == null) {
      return null;
    }
    var src = await compute(decodeImage, editorState.rawImageData);
    if (src == null) return null;
    if (editAction.needCrop) {
      src = copyCrop(
        src,
        x: cropRect.left.toInt(),
        y: cropRect.top.toInt(),
        width: cropRect.width.toInt(),
        height: cropRect.height.toInt(),
        radius: _actionTuple.borderRadius,
      );
    }
    if (editAction.needFlip) {
      final direction = editAction.flipY && editAction.flipX
          ? FlipDirection.both
          : editAction.flipY
              ? FlipDirection.horizontal
              : FlipDirection.vertical;
      src = flip(src, direction: direction);
    }
    if (editAction.hasRotateAngle) {
      src = copyRotate(src, angle: editAction.rotateAngle);
    }
    savePath ??= join(baseDir!, genImageFileName());
    if (_actionTuple.imageType == CropImageType.png) {
      if (!await encodePngFile(savePath, src)) return null;
    } else if (_actionTuple.imageType == CropImageType.jpg) {
      if (!await encodeJpgFile(savePath, src)) return null;
    } else if (_actionTuple.imageType == CropImageType.ico) {
      if (!await encodeIcoFile(savePath, src)) return null;
    }
    return savePath;
  }

  // 生成图片文件名称
  String genImageFileName() => '${Tool.genID()}.${_actionTuple.imageType.name}';

  // 确定裁剪比例
  void confirmRatio(double ratio) {
    updateActions(ratio: ratio);
    notifyListeners();
  }

  // 修改图片比例
  void changeRatio(double? ratio) {
    updateActions(ratio: ratio);
    notifyListeners();
  }

  // 水平翻转图片
  void changeFlip() {
    final editorState = editorKey.currentState;
    if (editorState == null) return;
    editorState.flip();
    updateActions(flip: editorState.editAction?.flipY);
  }

  // 旋转图片
  void changeRotate([bool right = true]) {
    final editorState = editorKey.currentState;
    if (editorState == null) return;
    editorState.rotate(right: right);
    final ratio = editorState.editAction!.rotateAngle / 360;
    updateActions(rotate: 6 * ratio);
  }

  // 重置图片状态
  void reset() {
    final editorState = editorKey.currentState;
    if (editorState == null) return;
    editorState.reset();
    updateActions(ratio: -1, flip: false, rotate: 0, borderRadius: 0);
  }

  // 更新操作元组参数
  void updateActions(
      {double? ratio,
      bool? flip,
      double? rotate,
      int? borderRadius,
      CropImageType? imageType}) {
    _actionTuple = (
      ratio: ratio ?? _actionTuple.ratio,
      flip: flip ?? _actionTuple.flip,
      rotate: rotate ?? _actionTuple.rotate,
      borderRadius: borderRadius ?? _actionTuple.borderRadius,
      imageType: imageType ?? _actionTuple.imageType,
    );
    notifyListeners();
  }
}

// 裁剪图片类型枚举
enum CropImageType { png, jpg, ico }
