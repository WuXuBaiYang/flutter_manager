import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';

/*
* 项目详情-linux平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformLinuxPage extends ProjectPlatformPage<
    ProjectPlatformLinuxPageProvider, LinuxPlatformInfoTuple> {
  const ProjectPlatformLinuxPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformLinuxPageProvider(context, PlatformType.linux),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<LinuxPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<LinuxPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformLinuxPageProvider>();
    return LabelPlatformItem(
      platform: provider.platform,
      label: platformInfo?.label ?? '',
      project: provider.getProjectInfo(context),
    );
  }
}

/*
* 项目详情-linux平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformLinuxPageProvider extends ProjectPlatformProvider {
  ProjectPlatformLinuxPageProvider(super.context, super.platform);
}
