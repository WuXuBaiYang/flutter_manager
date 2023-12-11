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

  // 提交回调
  final ValueChanged<String>? onSubmitted;

  // 水平风向占用格子数
  final int crossAxisCellCount;

  // 垂直方向高度
  final double mainAxisExtent;

  const LogoPlatformItem({
    super.key,
    required this.platform,
    required this.logos,
    this.project,
    this.onSubmitted,
    this.crossAxisCellCount = 5,
    this.mainAxisExtent = 140,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectPlatformItem.extent(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisExtent: mainAxisExtent,
      content: _buildContent(context),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        ProjectLogoGrid(logoList: logos),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => Tool.pickImageWithEdit(
              context,
              dialogTitle: '选择项目图标',
              absoluteRatio: CropAspectRatio.ratio1_1,
            ).then((result) {
              if (result == null) return;
              if (project == null) return onSubmitted?.call(result);
              final controller = StreamController<double>();
              context
                  .read<PlatformProvider>()
                  .updateLogo(platform, project!.path, result,
                      progressCallback: (c, t) => controller.add(c / t))
                  .loading(context,
                      progress: controller.stream, dismissible: false);
            }),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ),
      ],
    );
  }
}
