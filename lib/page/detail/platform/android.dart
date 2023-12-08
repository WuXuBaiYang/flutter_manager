import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/page/detail/platform/widgets/label_platform_item.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/platform_item.dart';
import 'widgets/provider.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPage
    extends ProjectPlatformPage<ProjectPlatformAndroidPageProvider> {
  const ProjectPlatformAndroidPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformAndroidPageProvider(context, PlatformType.android),
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
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    return Selector<PlatformProvider, String>(
      selector: (_, provider) => provider.androidInfo?.label ?? '',
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
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    return Selector<PlatformProvider, AndroidPlatformInfoTuple?>(
      selector: (_, provider) => provider.androidInfo,
      builder: (_, androidInfo, __) {
        final logos = androidInfo?.logo ?? [];
        return LogoPlatformItem(
          logos: logos,
          platform: provider.platform,
          project: provider.getProjectInfo(context),
        );
      },
    );
  }
}

/*
* 项目详情-android平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPageProvider extends ProjectPlatformProvider {
  ProjectPlatformAndroidPageProvider(super.context, super.platform);
}
