import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'widgets/base.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/options_platform_item.dart';

/*
* 项目详情-windows平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:04
*/
class ProjectPlatformWindowsView
    extends ProjectPlatformView<WindowsPlatformInfo> {
  const ProjectPlatformWindowsView({
    super.key,
    super.platform = PlatformType.windows,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
      PlatformInfo<WindowsPlatformInfo>? platformInfo) {
    return [
      LabelPlatformItem(
        platform: platform,
        label: platformInfo?.label ?? '',
        validator: (value) {
          // 验证输入内容是否为纯英文
          if (!WindowsPlatformTool.labelValidatorRegExp.hasMatch(value ?? '')) {
            return '仅支持英文、数字、下划线';
          }
          return null;
        },
      ),
      LogoPlatformItem(
        platform: platform,
        crossAxisCellCount: 2,
        logos: platformInfo?.logos ?? [],
      ),
      OptionsPlatformItem(platform: platform),
    ];
  }
}
