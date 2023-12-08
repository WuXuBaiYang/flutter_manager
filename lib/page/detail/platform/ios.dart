import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/provider.dart';

/*
* 项目详情-ios平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosPage
    extends ProjectPlatformPage<ProjectPlatformIosPageProvider> {
  const ProjectPlatformIosPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformIosPageProvider(context, PlatformType.ios),
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
    final provider = context.read<ProjectPlatformIosPageProvider>();
    return Selector<PlatformProvider, String>(
      selector: (_, provider) => provider.iosInfo?.label ?? '',
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
    final provider = context.read<ProjectPlatformIosPageProvider>();
    return Selector<PlatformProvider, IosPlatformInfoTuple?>(
      selector: (_, provider) => provider.iosInfo,
      builder: (_, tupleInfo, __) {
        final logos = tupleInfo?.logo ?? [];
        return LogoPlatformItem(
          logos: logos,
          mainAxisExtent: 610,
          platform: provider.platform,
          project: provider.getProjectInfo(context),
        );
      },
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
