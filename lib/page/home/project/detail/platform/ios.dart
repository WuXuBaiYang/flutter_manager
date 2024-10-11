import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'widgets/base.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/options_platform_item.dart';
import 'widgets/package_platform_item.dart';
import 'widgets/permission_platform_item.dart';

/*
* 项目详情-ios平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformIosView extends ProjectPlatformView<IosPlatformInfoTuple> {
  const ProjectPlatformIosView({
    super.key,
    super.platform = PlatformType.ios,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
          PlatformInfoTuple<IosPlatformInfoTuple>? platformInfo) =>
      [
        LabelPlatformItem(
          platform: platform,
          label: platformInfo?.label ?? '',
        ),
        PackagePlatformItem(
          platform: platform,
          package: platformInfo?.package ?? '',
        ),
        OptionsPlatformItem(platform: platform),
        PermissionPlatformItem(
          platform: platform,
          permissions: platformInfo?.permissions ?? [],
        ),
        LogoPlatformItem(
          mainAxisExtent: 610,
          platform: platform,
          logos: platformInfo?.logos ?? [],
        ),
      ];
}
