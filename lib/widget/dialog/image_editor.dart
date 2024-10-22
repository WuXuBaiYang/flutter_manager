import 'dart:io';
import 'dart:math';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/image.dart';
import 'package:flutter_manager/widget/popup_menu_button.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示图片编辑弹窗
Future<String?> showImageEditor(BuildContext context,
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

/*
* 图片编辑弹窗
* @author wuxubaiyang
* @Time 2023/12/6 8:48
*/
class ImageEditorDialog extends ProviderView<ImageEditorDialogProvider> {
  // 图片路径
  final String path;

  // 绝对比例（不可编辑）
  final CropAspectRatio? absoluteRatio;

  // 初始化裁剪比例
  final CropAspectRatio initializeRatio;

  ImageEditorDialog({
    super.key,
    required this.path,
    this.absoluteRatio,
    this.initializeRatio = CropAspectRatio.ratio1_1,
  });

  @override
  ImageEditorDialogProvider createProvider(BuildContext context) =>
      ImageEditorDialogProvider(context, (
        rotate: 0,
        borderRadius: 0,
        ratio: initializeRatio,
        imageType: ImageType.png,
      ));

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: Row(children: [
        const Expanded(child: Text('图片裁剪')),
        _buildImageType(context),
      ]),
      content: _buildContent(context),
      decoration: CustomDialogDecoration(
        constraints: const BoxConstraints.tightFor(width: 480, height: 350),
      ),
      actions: [
        TextButton(
          child: const Text('使用原图'),
          onPressed: () => Navigator.pop(context, path),
        ),
        TextButton(
          child: const Text('另存为'),
          onPressed: () => provider.saveOtherPath().loading(context),
        ),
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () => provider.saveCrop().loading(context),
        ),
      ],
    );
  }

  // 构建图片类型选择器
  Widget _buildImageType(BuildContext context) {
    return createSelector<ImageType>(
      selector: (_, provider) => provider.action.imageType,
      builder: (_, imageType, __) {
        return Row(children: [
          if (imageType == ImageType.ico)
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
            child: DropdownButton<ImageType>(
              value: imageType,
              icon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.image),
              ),
              onChanged: (v) => provider.updateActions(imageType: v),
              items: ImageType.values
                  .map((e) => DropdownMenuItem<ImageType>(
                        value: e,
                        child: Text(' .${e.name}'),
                      ))
                  .toList(),
            ),
          ),
        ]);
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Column(children: [
      Expanded(child: _buildImageEditor(context)),
      const SizedBox(height: 14),
      _buildImageEditorActions(context),
    ]);
  }

  // 构建图片编辑器
  Widget _buildImageEditor(BuildContext context) {
    return Listener(
      onPointerSignal: provider.changeScale,
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: createSelector<ImageEditorAction>(
          selector: (_, provider) => provider.action,
          builder: (_, result, __) {
            return CustomImageCrop(
              ratio: result.ratio.ratio,
              image: FileImage(File(path)),
              shape: CustomCropShape.Square,
              borderRadius: result.borderRadius,
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
    return createSelector<ImageEditorAction>(
      selector: (_, provider) => provider.action,
      builder: (_, action, __) {
        return Row(children: [
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
                  value: action.borderRadius,
                  label: '${action.borderRadius.round()}px',
                  onChanged: (v) => provider.updateActions(borderRadius: v),
                ),
              ),
            ),
          ),
          const Spacer(),
          Transform.rotate(
            angle: action.rotate,
            child: IconButton.filled(
              iconSize: 16,
              tooltip: '向左旋转',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.rotate_left_rounded),
              onPressed: () => provider.changeRotate(false),
            ),
          ),
          const SizedBox(width: 14),
          Transform.rotate(
            angle: action.rotate,
            child: IconButton.filled(
              iconSize: 16,
              tooltip: '向右旋转',
              onPressed: provider.changeRotate,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.rotate_right_rounded),
            ),
          ),
          const SizedBox(width: 14),
          if (!ratioDisable) ...[
            CustomPopupMenuButton<CropAspectRatio>.filled(
              iconSize: 16,
              tooltip: '裁剪比例',
              icon: const Icon(Icons.aspect_ratio),
              itemBuilder: (_) => CropAspectRatio.values
                  .map((e) => PopupMenuItem<CropAspectRatio>(
                        value: e,
                        child: Text(e.label),
                      ))
                  .toList(),
              onSelected: provider.changeRatio,
            ),
            const SizedBox(width: 14),
          ],
          IconButton.filledTonal(
            iconSize: 16,
            tooltip: '重置',
            onPressed: provider.reset,
            icon: const Icon(Icons.cleaning_services_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ]);
      },
    );
  }
}

// 图片编辑操作项元组
typedef ImageEditorAction = ({
  CropAspectRatio ratio,
  double rotate,
  double borderRadius,
  ImageType imageType,
});

class ImageEditorDialogProvider extends BaseProvider {
  // 图片编辑控制器
  final controller = CustomImageCropController();

  // 缓存初始化字段
  final ImageEditorAction _initializeAction;

  ImageEditorDialogProvider(super.context, this._initializeAction);

  // 图片编辑操作参数元组
  late ImageEditorAction _action = _initializeAction;

  // 获取图片编辑操作参数元组
  ImageEditorAction get action => _action;

  // 生成图片文件名称
  String get _imageFileName => '${genID()}.${_action.imageType.name}';

  // 另存为其他路径
  Future<String?> saveOtherPath() async {
    try {
      final result = await Picker.directory(dialogTitle: '选择保存路径');
      if (result == null) return null;
      return saveCrop(savePath: join(result, _imageFileName));
    } catch (e) {
      showNoticeError(e.toString(), title: '图片另存为失败');
    }
    return null;
  }

  // 保存裁剪后的图片并返回路径
  Future<String?> saveCrop({String? savePath}) async {
    try {
      final baseDir = await FileTool.getCachePath();
      final cropImage = await controller.onCropImage();
      if (baseDir == null || cropImage == null) return null;
      savePath ??= join(baseDir, _imageFileName);
      final result = await ImageTool.saveData(
          cropImage.bytes, savePath, _action.imageType);
      if (result != null && context.mounted) context.pop(result);
      return result;
    } catch (e) {
      showNoticeError(e.toString(), title: '图片裁剪失败');
    }
    return null;
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
  void changeScale(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final scaleUp = event.scrollDelta.dy > 0;
    final scale = controller.cropImageData?.scale ?? 1;
    if (scaleUp && scale < 0.5) return;
    controller.addTransition(CropImageData(
      scale: scaleUp ? 0.93 : 1.07,
    ));
  }

  // 重置图片状态
  void reset() {
    controller.reset();
    _action = _initializeAction;
    notifyListeners();
  }

  // 更新操作元组参数
  void updateActions({
    CropAspectRatio? ratio,
    double? rotate,
    double? borderRadius,
    ImageType? imageType,
  }) {
    _action = (
      ratio: ratio ?? _action.ratio,
      rotate: rotate ?? _action.rotate,
      borderRadius: borderRadius ?? _action.borderRadius,
      imageType: imageType ?? _action.imageType,
    );
    notifyListeners();
  }
}

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
  Ratio get ratio => switch (this) {
        CropAspectRatio.ratio1_1 => Ratio(width: 1, height: 1),
        CropAspectRatio.ratio4_3 => Ratio(width: 4, height: 3),
        CropAspectRatio.ratio3_4 => Ratio(width: 3, height: 4),
        CropAspectRatio.ratio16_9 => Ratio(width: 16, height: 9),
        CropAspectRatio.ratio9_16 => Ratio(width: 9, height: 16),
      };

  String get label => switch (this) {
        CropAspectRatio.ratio1_1 => '1:1',
        CropAspectRatio.ratio4_3 => '4:3',
        CropAspectRatio.ratio3_4 => '3:4',
        CropAspectRatio.ratio16_9 => '16:9',
        CropAspectRatio.ratio9_16 => '9:16',
      };
}
