import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/dialog/android_sign_key.dart';
import 'widgets/base.dart';
import 'widgets/label_platform_item.dart';
import 'widgets/logo_platform_item.dart';
import 'widgets/options_platform_item.dart';
import 'widgets/package_platform_item.dart';
import 'widgets/permission_platform_item.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidView
    extends ProjectPlatformView<AndroidPlatformInfo> {
  const ProjectPlatformAndroidView({
    super.key,
    super.platform = PlatformType.android,
  });

  @override
  List<Widget> buildPlatformItems(BuildContext context,
          PlatformInfo<AndroidPlatformInfo>? platformInfo) =>
      [
        LabelPlatformItem(
          platform: platform,
          label: platformInfo?.label ?? '',
        ),
        PackagePlatformItem(
          platform: platform,
          package: platformInfo?.package ?? '',
        ),
        OptionsPlatformItem(platform: platform, actions: [
          IconButton.filled(
            tooltip: '创建签名',
            isSelected: false,
            icon: const Icon(Icons.key_rounded),
            onPressed: () => showAndroidSignKey(context),
          ),
        ]),
        PermissionPlatformItem(
          platform: platform,
          permissions: platformInfo?.permissions ?? [],
        ),
        LogoPlatformItem(
          platform: platform,
          logos: platformInfo?.logos ?? [],
        ),
      ];
}
