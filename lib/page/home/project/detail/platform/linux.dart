import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'widgets/base.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/options_platform_item.dart';

/*
* 项目详情-linux平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformLinuxView
    extends ProjectPlatformView<LinuxPlatformInfoTuple> {
  const ProjectPlatformLinuxView({
    super.key,
    super.platform = PlatformType.linux,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<LinuxPlatformInfoTuple>? platformInfo) {
    return [
      LabelPlatformItem(
        platform: platform,
        label: platformInfo?.label ?? '',
      ),
      OptionsPlatformItem(platform: platform),
    ];
  }
}
