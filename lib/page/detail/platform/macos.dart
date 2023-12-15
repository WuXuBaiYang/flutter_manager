import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/options_platform_item.dart';

/*
* 项目详情-macos平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformMacosView
    extends ProjectPlatformView<MacosPlatformInfoTuple> {
  const ProjectPlatformMacosView({
    super.key,
    super.platform = PlatformType.macos,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<MacosPlatformInfoTuple>? platformInfo) {
    return [
      LabelPlatformItem(
        platform: platform,
        label: platformInfo?.label ?? '',
      ),
      LogoPlatformItem(
        platform: platform,
        mainAxisExtent: 340,
        logos: platformInfo?.logos ?? [],
      ),
      OptionsPlatformItem(platform: platform),
    ];
  }
}
