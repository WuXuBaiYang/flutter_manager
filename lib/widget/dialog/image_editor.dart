import 'dart:io';
import 'dart:math';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  final CropAspectRatio? absoluteRatio;

  // 初始化裁剪比例
  final CropAspectRatio initializeRatio;

  const ImageEditorDialog({
    super.key,
    required this.path,
    this.absoluteRatio,
    this.initializeRatio = CropAspectRatio.ratio1_1,
  });

  // 展示弹窗
  static Future<String?> show(BuildContext context,
      {required String path, CropAspectRatio? absoluteRatio}) {
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
      create: (_) => ImageEditorDialogProvider((
        ratio: initializeRatio,
        rotate: 0,
        borderRadius: 0,
        imageType: CropImageType.png,
      )),
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
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final delta = event.scrollDelta.dy;
          provider.changeScale(delta > 0);
        }
      },
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Selector<ImageEditorDialogProvider, (CropAspectRatio, double)>(
          selector: (_, provider) {
            final actionTuple = provider.actionTuple;
            return (actionTuple.ratio, actionTuple.borderRadius);
          },
          builder: (_, tuple, __) {
            return CustomImageCrop(
              ratio: tuple.$1.ratio,
              borderRadius: tuple.$2,
              image: FileImage(File(path)),
              shape: CustomCropShape.Square,
              backgroundColor: Colors.transparent,
              imageFit: CustomImageFit.fillVisibleSpace,
              cropController: provider.controller,
            );
          },
        ),
      ),
    );
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
                  icon: const Icon(Icons.rounded_corner_rounded),
                  onPressed: () => provider.updateActions(borderRadius: 0),
                  label: Slider(
                    max: 80,
                    value: actionTuple.borderRadius,
                    label: '${actionTuple.borderRadius.round()}px',
                    onChanged: (v) => provider.updateActions(borderRadius: v),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Transform.rotate(
              angle: actionTuple.rotate,
              child: IconButton.filled(
                iconSize: 16,
                tooltip: '向左旋转',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.rotate_left_rounded),
                onPressed: () => provider.changeRotate(false),
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
                child: DropdownButton<CropAspectRatio>(
                  alignment: Alignment.center,
                  value: absoluteRatio ?? actionTuple.ratio,
                  icon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.aspect_ratio),
                  ),
                  onChanged: !ratioDisable ? provider.changeRatio : null,
                  items: CropAspectRatio.values
                      .map((e) => DropdownMenuItem<CropAspectRatio>(
                            value: e,
                            child: Text(e.label),
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
  CropAspectRatio ratio,
  double rotate,
  double borderRadius,
  CropImageType imageType,
});

/*
* 图片编辑弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/6 8:51
*/
class ImageEditorDialogProvider extends BaseProvider {
  // 图片编辑控制器
  final controller = CustomImageCropController();

  // 缓存初始化字段
  final ImageEditorActionTuple _initializeActionTuple;

  // 图片编辑操作参数元组
  ImageEditorActionTuple _actionTuple;

  // 获取图片编辑操作参数元组
  ImageEditorActionTuple get actionTuple => _actionTuple;

  ImageEditorDialogProvider(this._initializeActionTuple)
      : _actionTuple = _initializeActionTuple;

  // 生成图片文件名称
  String get _imageFileName => '${Tool.genID()}.${_actionTuple.imageType.name}';

  // 另存为其他路径
  Future<String?> saveOtherPath(String path) =>
      saveCrop(savePath: join(path, _imageFileName));

  // 保存裁剪后的图片并返回路径
  Future<String?> saveCrop({String? savePath}) async {
    final baseDir = await Tool.getFileCachePath();
    final cropImage = await controller.onCropImage();
    if (baseDir == null || cropImage == null) return null;
    final src = await compute(decodeImage, cropImage.bytes);
    if (src == null) return null;
    savePath ??= join(baseDir, _imageFileName);
    switch (_actionTuple.imageType) {
      case CropImageType.png:
        if (!await encodePngFile(savePath, src)) return null;
      case CropImageType.jpg:
        if (!await encodeJpgFile(savePath, src)) return null;
      case CropImageType.ico:
        if (!await encodeIcoFile(savePath, src)) return null;
    }
    return savePath;
  }

  // 修改图片圆角
  void changeBorderRadius(double radius) {
    updateActions(borderRadius: radius);
  }

  // 修改图片比例
  void changeRatio(CropAspectRatio? ratio) {
    updateActions(ratio: ratio);
  }

  // 旋转图片
  void changeRotate([bool right = true]) {
    final angle = controller.cropImageData?.angle ?? 0;
    final step = right ? pi / 2 : -(pi / 2);
    updateActions(rotate: angle + step);
    controller.addTransition(CropImageData(angle: step));
  }

  // 缩放图片
  void changeScale(bool scaleUp) {
    final scale = controller.cropImageData?.scale ?? 1;
    if (scaleUp && scale < 0.5) return;
    controller.addTransition(CropImageData(
      scale: scaleUp ? 0.93 : 1.07,
    ));
  }

  // 重置图片状态
  void reset() {
    controller.reset();
    _actionTuple = _initializeActionTuple;
    notifyListeners();
  }

  // 更新操作元组参数
  void updateActions({
    CropAspectRatio? ratio,
    double? rotate,
    double? borderRadius,
    CropImageType? imageType,
  }) {
    _actionTuple = (
      ratio: ratio ?? _actionTuple.ratio,
      rotate: rotate ?? _actionTuple.rotate,
      borderRadius: borderRadius ?? _actionTuple.borderRadius,
      imageType: imageType ?? _actionTuple.imageType,
    );
    notifyListeners();
  }
}

// 裁剪图片类型枚举
enum CropImageType { png, jpg, ico }

// 图片裁剪比例枚举
enum CropAspectRatio {
  ratio1_1,
  ratio4_3,
  ratio3_4,
  ratio16_9,
  ratio9_16,
}

// 扩展裁剪比例枚举获取ratio字段
extension CropAspectRatioExtension on CropAspectRatio {
  Ratio get ratio => {
        CropAspectRatio.ratio1_1: Ratio(width: 1, height: 1),
        CropAspectRatio.ratio4_3: Ratio(width: 4, height: 3),
        CropAspectRatio.ratio3_4: Ratio(width: 3, height: 4),
        CropAspectRatio.ratio16_9: Ratio(width: 16, height: 9),
        CropAspectRatio.ratio9_16: Ratio(width: 9, height: 16),
      }[this]!;

  String get label => {
        CropAspectRatio.ratio1_1: '1:1',
        CropAspectRatio.ratio4_3: '4:3',
        CropAspectRatio.ratio3_4: '3:4',
        CropAspectRatio.ratio16_9: '16:9',
        CropAspectRatio.ratio9_16: '9:16',
      }[this]!;
}
