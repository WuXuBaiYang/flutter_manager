import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/widgets/base.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';

/*
* 项目详情-web平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:03
*/
class ProjectPlatformWebView extends ProjectPlatformView<WebPlatformInfoTuple> {
  const ProjectPlatformWebView({
    super.key,
    super.platform = PlatformType.web,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfoTuple<WebPlatformInfoTuple>? platformInfo) {
    return [
      LabelPlatformItem(
        platform: platform,
        label: platformInfo?.label ?? '',
      ),
      LogoPlatformItem(
        platform: platform,
        mainAxisExtent: 250,
        logos: platformInfo?.logos ?? [],
      ),
    ];
  }
}
