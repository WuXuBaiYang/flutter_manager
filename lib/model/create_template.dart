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

  // 将参数转化成命令
  List<String> toCommand() => [
    '--flutter-bin',
    flutterBin,
    '--project-name',
    projectName,
    '--app-name',
    appName ?? projectName,
    '--db-name',
    dbName ?? projectName,
    '--dev-url',
    devUrl,
    '--prod-url',
    prodUrl ?? devUrl,
    '--target-dir',
    targetDir,
    '--description',
    description ?? '',
    '--platforms',
    platforms.entries.map((e) => e.key.name).join(','),
    for (MapEntry e in platforms.entries) ...e.value.toCommand(),
    if (openWhenFinish == true) '--open-when-finish',
  ];
}

// 模板平台(基类)
@freezed
abstract class TemplatePlatform with _$TemplatePlatform {
  const TemplatePlatform._();

  const factory TemplatePlatform({required PlatformType type}) =
      _TemplatePlatform;

  factory TemplatePlatform.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformFromJson(json);

  static TemplatePlatform create({required PlatformType type}) =>
      switch (type) {
        PlatformType.android => TemplatePlatformAndroid.create(packageName: ''),
        PlatformType.ios => TemplatePlatformIos.create(bundleId: ''),
        PlatformType.macos => TemplatePlatformMacos.create(bundleId: ''),
        _ => TemplatePlatform(type: type),
      };

  // 获取所有参数命令行
  List<String> toCommand() => [];
}

// android平台
@freezed
abstract class TemplatePlatformAndroid
    with _$TemplatePlatformAndroid
    implements TemplatePlatform {
  const TemplatePlatformAndroid._();

  const factory TemplatePlatformAndroid({
    required PlatformType type,
    required String packageName,
  }) = _TemplatePlatformAndroid;

  factory TemplatePlatformAndroid.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformAndroidFromJson(json);

  static TemplatePlatformAndroid create({required String packageName}) =>
      TemplatePlatformAndroid(
        type: PlatformType.android,
        packageName: packageName,
      );

  // 获取所有参数命令行
  @override
  List<String> toCommand() => ['--android-package', packageName];
}

// ios平台
@freezed
abstract class TemplatePlatformIos
    with _$TemplatePlatformIos
    implements TemplatePlatform {
  const TemplatePlatformIos._();

  const factory TemplatePlatformIos({
    required PlatformType type,
    required String bundleId,
  }) = _TemplatePlatformIos;

  factory TemplatePlatformIos.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformIosFromJson(json);

  static TemplatePlatformIos create({required String bundleId}) =>
      TemplatePlatformIos(type: PlatformType.ios, bundleId: bundleId);

  // 获取所有参数命令行
  @override
  List<String> toCommand() => ['--ios-bundle-id', bundleId];
}

// macos平台
@freezed
abstract class TemplatePlatformMacos
    with _$TemplatePlatformMacos
    implements TemplatePlatform {
  const TemplatePlatformMacos._();

  const factory TemplatePlatformMacos({
    required PlatformType type,
    required String bundleId,
  }) = _TemplatePlatformMacos;

  factory TemplatePlatformMacos.fromJson(Map<String, dynamic> json) =>
      _$TemplatePlatformMacosFromJson(json);

  static TemplatePlatformMacos create({required String bundleId}) =>
      TemplatePlatformMacos(type: PlatformType.macos, bundleId: bundleId);

  // 获取所有参数命令行
  @override
  List<String> toCommand() => ['--macos-bundle-id', bundleId];
}
