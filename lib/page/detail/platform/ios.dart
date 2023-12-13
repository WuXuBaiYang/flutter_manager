import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
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
        LogoPlatformItem(
          mainAxisExtent: 610,
          platform: platform,
          logos: platformInfo?.logos ?? [],
        ),
        PermissionPlatformItem(
          platform: platform,
          permissions: platformInfo?.permissions ?? [],
        ),
      ];
}
