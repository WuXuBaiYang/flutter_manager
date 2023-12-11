import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/dialog/image_editor.dart';
import 'package:provider/provider.dart';
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

  // 项目信息
  final Project? project;

  // 图标列表
  final List<PlatformLogoTuple> logos;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const LogoPlatformItem({
    super.key,
    required this.platform,
    required this.logos,
    this.project,
    this.crossAxisCellCount = 5,
    this.mainAxisExtent = 150,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem.extent(
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
    return IconButton(
      iconSize: 18,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.edit_outlined),
      onPressed: () => Tool.pickImageWithEdit(
        context,
        dialogTitle: '选择项目图标',
        absoluteRatio: CropAspectRatio.ratio1_1,
      ).then((result) {
        if (result == null) return;
        final controller = StreamController<double>();
        context
            .read<PlatformProvider>()
            .updateLogo(platform, project?.path, result,
                progressCallback: (c, t) => controller.add(c / t))
            .loading(context, progress: controller.stream, dismissible: false);
      }),
    );
  }
}
