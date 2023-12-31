import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-web平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformWebPage extends ProjectPlatformPage<
    ProjectPlatformWebPageProvider, WebPlatformInfoTuple> {
  const ProjectPlatformWebPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformWebPageProvider(context, PlatformType.web),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<WebPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
      _buildLogoItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<WebPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformWebPageProvider>();
    return LabelPlatformItem(
      project: provider.project,
      platform: provider.platform,
      label: platformInfo?.label ?? '',
    );
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context,
      PlatformInfoTuple<WebPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformWebPageProvider>();
    return LogoPlatformItem(
      mainAxisExtent: 250,
      project: provider.project,
      platform: provider.platform,
      logos: platformInfo?.logos ?? [],
    );
  }
}

/*
* 项目详情-web平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformWebPageProvider extends ProjectPlatformProvider {
  ProjectPlatformWebPageProvider(super.context, super.platform);
}
