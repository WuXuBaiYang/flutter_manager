import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_template.g.dart';

part 'create_template.freezed.dart';

// 模板创建参数对象
@freezed
abstract class CreateTemplate with _$CreateTemplate {
  const CreateTemplate._();

  const factory CreateTemplate({
    required String flutterBin,
    required String projectName,
    required String devUrl,
    required String targetDir,
    required Map<PlatformType, TemplatePlatform> platforms,
    String? appName,
    String? dbName,
    String? prodUrl,
    String? description,
    bool? openWhenFinish,
  }) = _CreateTemplate;

  factory CreateTemplate.fromJson(Map<String, dynamic> json) =>
      _$CreateTemplateFromJson(json);

  static CreateTemplate empty() => CreateTemplate(
    flutterBin: '',
    projectName: '',
    devUrl: '',
    targetDir: '',
    platforms: {},
  );

  // 添加一个平台
  CreateTemplate addPlatform(TemplatePlatform platform) =>
      copyWith(platforms: {...platforms, platform.platform: platform});

  // 添加android平台
  CreateTemplate addPlatformAndroid(String packageName) =>
      addPlatform(TemplatePlatformAndroid.create(packageName: packageName));

  // 添加ios平台
  CreateTemplate addPlatformIos(String bundleId) =>
      addPlatform(TemplatePlatformIos.create(bundleId: bundleId));

  // 添加macos平台
  CreateTemplate addPlatformMacos(String bundleId) =>
      addPlatform(TemplatePlatformMacos.create(bundleId: bundleId));

  // 将参数转化成命令
  String toCommand() =>
      '--flutter-bin "$flutterBin" --project-name $projectName --app-name "${appName ?? projectName}" --db-name "${dbName ?? projectName}" '
      '--dev-url "$devUrl" --prod-url "${prodUrl ?? devUrl}" '
      '--target-dir "$targetDir" --description "${description ?? ''}" '
      '--platforms "${platforms.entries.map((e) => e.key.name).join(',')}" ${platforms.entries.map((e) => e.value.toCommand()).join(' ')}'
      '${openWhenFinish == true ? '--open-when-finish' : ''}';
}

// 模板平台(基类)
@freezed
abstract class TemplatePlatform with _$TemplatePlatform {
  const TemplatePlatform._();

  const factory TemplatePlatform({required PlatformType platform}) =
      _TemplatePlatform;

  factory TemplatePlatform.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformFromJson(json);

  static TemplatePlatform create({required PlatformType platform}) =>
      TemplatePlatform(platform: platform);

  // 获取所有参数命令行
  String toCommand() => '';
}

// android平台
@freezed
abstract class TemplatePlatformAndroid
    with _$TemplatePlatformAndroid
    implements TemplatePlatform {
  const TemplatePlatformAndroid._();

  const factory TemplatePlatformAndroid({
    required PlatformType platform,
    required String packageName,
  }) = _TemplatePlatformAndroid;

  factory TemplatePlatformAndroid.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformAndroidFromJson(json);

  static TemplatePlatformAndroid create({required String packageName}) =>
      TemplatePlatformAndroid(
        platform: PlatformType.android,
        packageName: packageName,
      );

  // 获取所有参数命令行
  @override
  String toCommand() => '--android-package "$packageName"';
}

// ios平台
@freezed
abstract class TemplatePlatformIos
    with _$TemplatePlatformIos
    implements TemplatePlatform {
  const TemplatePlatformIos._();

  const factory TemplatePlatformIos({
    required PlatformType platform,
    required String bundleId,
  }) = _TemplatePlatformIos;

  factory TemplatePlatformIos.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformIosFromJson(json);

  static TemplatePlatformIos create({required String bundleId}) =>
      TemplatePlatformIos(platform: PlatformType.ios, bundleId: bundleId);

  // 获取所有参数命令行
  @override
  String toCommand() => '--ios-bundle-id "$bundleId"';
}

// macos平台
@freezed
abstract class TemplatePlatformMacos
    with _$TemplatePlatformMacos
    implements TemplatePlatform {
  const TemplatePlatformMacos._();

  const factory TemplatePlatformMacos({
    required PlatformType platform,
    required String bundleId,
  }) = _TemplatePlatformMacos;

  factory TemplatePlatformMacos.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformMacosFromJson(json);

  static TemplatePlatformMacos create({required String bundleId}) =>
      TemplatePlatformMacos(platform: PlatformType.macos, bundleId: bundleId);

  // 获取所有参数命令行
  @override
  String toCommand() => '--macos-bundle-id "$bundleId"';
}
