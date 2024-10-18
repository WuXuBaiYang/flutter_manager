import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/project_logo.dart';
import 'package:flutter_manager/widget/dialog/image_editor.dart';
import 'package:jtech_base/jtech_base.dart';
import 'platform_item.dart';
import 'provider.dart';

/*
* 项目平台logo项组件
* @author wuxubaiyang
* @Time 2023/12/8 9:55
*/
class LogoPlatformItem extends StatelessWidget {
  // 平台
  final PlatformType platform;

  // 图标列表
  final List<PlatformLogo> logos;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const LogoPlatformItem({
    super.key,
    required this.platform,
    required this.logos,
    this.crossAxisCellCount = 5,
    this.mainAxisExtent = 150,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem(
      title: '项目图标',
      actions: [
        _buildEditLogoButton(context),
      ],
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: mainAxisExtent,
      content: ProjectLogoGrid(logoList: logos),
    );
  }

  // 构建编辑图标按钮
  Widget _buildEditLogoButton(BuildContext context) {
    final platformProvider = context.read<PlatformProvider>();
    return IconButton(
      iconSize: 14,
      icon: const Icon(Icons.edit),
      visualDensity: VisualDensity.compact,
      onPressed: () async {
        var result = await Picker.image(dialogTitle: '选择项目图标');
        if (result == null || !context.mounted) return;
        result = await showImageEditor(context,
            path: result, absoluteRatio: CropAspectRatio.ratio1_1);
        if (result == null || !context.mounted) return;
        final controller = StreamController<double>();
        platformProvider
            .updateLogo(platform, result,
                progressCallback: (c, t) => controller.add(c / t))
            .loading(context, dismissible: false);
      },
    );
  }
}
