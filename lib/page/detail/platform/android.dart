import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/page/detail/platform/widgets/label_platform_item.dart';
import 'package:flutter_manager/page/detail/platform/widgets/options_platform_item.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/permission_platform_item.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidView
    extends ProjectPlatformView<AndroidPlatformInfoTuple> {
  const ProjectPlatformAndroidView({
    super.key,
    super.platform = PlatformType.android,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
          PlatformInfoTuple<AndroidPlatformInfoTuple>? platformInfo) =>
      [
        LabelPlatformItem(
          platform: platform,
          label: platformInfo?.label ?? '',
        ),
        LogoPlatformItem(
          platform: platform,
          logos: platformInfo?.logos ?? [],
        ),
        PermissionPlatformItem(
          platform: platform,
          permissions: platformInfo?.permissions ?? [],
        ),
        OptionsPlatformItem(platform: platform),
      ];
}
