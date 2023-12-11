import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-macos平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPage extends ProjectPlatformPage<
    ProjectPlatformMacosPageProvider, MacosPlatformInfoTuple> {
  const ProjectPlatformMacosPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformMacosPageProvider(context, PlatformType.macos),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<MacosPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
      _buildLogoItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<MacosPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformMacosPageProvider>();
    return LabelPlatformItem(
      project: provider.project,
      platform: provider.platform,
      label: platformInfo?.label ?? '',
    );
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context,
      PlatformInfoTuple<MacosPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformMacosPageProvider>();
    return LogoPlatformItem(
      mainAxisExtent: 320,
      project: provider.project,
      platform: provider.platform,
      logos: platformInfo?.logos ?? [],
    );
  }
}

/*
* 项目详情-macos平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosPageProvider extends ProjectPlatformProvider {
  ProjectPlatformMacosPageProvider(super.context, super.platform);
}
