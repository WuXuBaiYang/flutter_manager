import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/provider.dart';

/*
* 项目详情-windows平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsPage
    extends ProjectPlatformPage<ProjectPlatformWindowsPageProvider> {
  const ProjectPlatformWindowsPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformWindowsPageProvider(context, PlatformType.windows),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context) {
    return [
      _buildLabelItem(context),
      _buildLogoItem(context),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context) {
    final provider = context.read<ProjectPlatformWindowsPageProvider>();
    return Selector<PlatformProvider, String>(
      selector: (_, provider) => provider.windowsInfo?.label ?? '',
      builder: (_, label, __) {
        return LabelPlatformItem(
          project: provider.getProjectInfo(context),
          platform: provider.platform,
          label: label,
        );
      },
    );
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context) {
    final provider = context.read<ProjectPlatformWindowsPageProvider>();
    return Selector<PlatformProvider, WindowsPlatformInfoTuple?>(
      selector: (_, provider) => provider.windowsInfo,
      builder: (_, tupleInfo, __) {
        final logos = tupleInfo?.logo ?? [];
        return LogoPlatformItem(
          logos: logos,
          crossAxisCellCount: 2,
          platform: provider.platform,
          project: provider.getProjectInfo(context),
        );
      },
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
