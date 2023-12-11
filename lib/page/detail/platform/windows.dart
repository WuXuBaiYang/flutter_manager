import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-windows平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsPage extends ProjectPlatformPage<
    ProjectPlatformWindowsPageProvider, WindowsPlatformInfoTuple> {
  const ProjectPlatformWindowsPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformWindowsPageProvider(context, PlatformType.windows),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<WindowsPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
      _buildLogoItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<WindowsPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformWindowsPageProvider>();
    return LabelPlatformItem(
        project: provider.project,
        platform: provider.platform,
        label: platformInfo?.label ?? '',
        validator: (value) {
          // 验证输入内容是否为纯英文
          if (!WindowsPlatformTool.labelValidatorRegExp.hasMatch(value ?? '')) {
            return '仅支持英文、数字、下划线';
          }
          return null;
        });
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context,
      PlatformInfoTuple<WindowsPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformWindowsPageProvider>();
    return LogoPlatformItem(
      crossAxisCellCount: 2,
      project: provider.project,
      platform: provider.platform,
      logos: platformInfo?.logos ?? [],
    );
  }
}

/*
* 项目详情-windows平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsPageProvider extends ProjectPlatformProvider {
  ProjectPlatformWindowsPageProvider(super.context, super.platform);
}
