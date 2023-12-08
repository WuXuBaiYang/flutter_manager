import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/page/detail/platform/widgets/label_platform_item.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPage extends ProjectPlatformPage<
    ProjectPlatformAndroidPageProvider, AndroidPlatformInfoTuple> {
  const ProjectPlatformAndroidPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformAndroidPageProvider(context, PlatformType.android),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<AndroidPlatformInfoTuple>? platformInfo) {
    return [
      _buildLabelItem(context, platformInfo),
      _buildLogoItem(context, platformInfo),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context,
      PlatformInfoTuple<AndroidPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    return LabelPlatformItem(
      platform: provider.platform,
      label: platformInfo?.label ?? '',
      project: provider.getProjectInfo(context),
    );
  }

  // 构建logo项
  Widget _buildLogoItem(BuildContext context,
      PlatformInfoTuple<AndroidPlatformInfoTuple>? platformInfo) {
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    return LogoPlatformItem(
      platform: provider.platform,
      logos: platformInfo?.logos ?? [],
      project: provider.getProjectInfo(context),
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
