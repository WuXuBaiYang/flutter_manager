import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-ios平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPage extends ProjectPlatformPage<
    ProjectPlatformIosPageProvider, IosPlatformInfoTuple> {
  const ProjectPlatformIosPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformIosPageProvider(context, PlatformType.ios),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<IosPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
      _buildLogoItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<IosPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformIosPageProvider>();
    return LabelPlatformItem(
      project: provider.project,
      platform: provider.platform,
      label: platformInfo?.label ?? '',
    );
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context,
      PlatformInfoTuple<IosPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformIosPageProvider>();
    return LogoPlatformItem(
      mainAxisExtent: 590,
      project: provider.project,
      platform: provider.platform,
      logos: platformInfo?.logos ?? [],
    );
  }
}

/*
* 项目详情-ios平台信息页-状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPageProvider extends ProjectPlatformProvider {
  ProjectPlatformIosPageProvider(super.context, super.platform);
}
