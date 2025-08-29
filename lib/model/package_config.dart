import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_config.g.dart';

part 'package_config.freezed.dart';

@freezed
abstract class PackageConfig with _$PackageConfig {
  const PackageConfig._();

  const factory PackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _PackageConfig;

  // 获取打包脚本集合
  List<String> getScriptList() => [
    if (runPubGet) 'flutter pub get',
    if (runBuildRunner) 'dart run build_runner build',
  ];

  // 获取当前平台类型
  PlatformType get platform => throw UnimplementedError();

  factory PackageConfig.fromJson(Map<String, dynamic> json) =>
      _$PackageConfigFromJson(json);
}

@freezed
abstract class AndroidPackageConfig extends PackageConfig
    with _$AndroidPackageConfig {
  const AndroidPackageConfig._() : super._();

  const factory AndroidPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _AndroidPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build apk'];
  }

  @override
  PlatformType get platform => PlatformType.android;

  factory AndroidPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$AndroidPackageConfigFromJson(json);
}

@freezed
abstract class IosPackageConfig extends PackageConfig with _$IosPackageConfig {
  const IosPackageConfig._() : super._();

  const factory IosPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _IosPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build ipa'];
  }

  @override
  PlatformType get platform => PlatformType.ios;

  factory IosPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$IosPackageConfigFromJson(json);
}

@freezed
abstract class WebPackageConfig extends PackageConfig with _$WebPackageConfig {
  const WebPackageConfig._() : super._();

  const factory WebPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _WebPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build web'];
  }

  @override
  PlatformType get platform => PlatformType.web;

  factory WebPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$WebPackageConfigFromJson(json);
}

@freezed
abstract class WindowsPackageConfig extends PackageConfig
    with _$WindowsPackageConfig {
  const WindowsPackageConfig._() : super._();

  const factory WindowsPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _WindowsPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build windows'];
  }

  @override
  PlatformType get platform => PlatformType.windows;

  factory WindowsPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$WindowsPackageConfigFromJson(json);
}

@freezed
abstract class MacosPackageConfig extends PackageConfig
    with _$MacosPackageConfig {
  const MacosPackageConfig._() : super._();

  const factory MacosPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _MacosPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build macos'];
  }

  @override
  PlatformType get platform => PlatformType.macos;

  factory MacosPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$MacosPackageConfigFromJson(json);
}

@freezed
abstract class LinuxPackageConfig extends PackageConfig
    with _$LinuxPackageConfig {
  const LinuxPackageConfig._() : super._();

  const factory LinuxPackageConfig({
    required bool runPubGet,
    required bool runBuildRunner,
    required String? outputPath,
    required String? label,
    required bool openDirWhenComplete,
  }) = _LinuxPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build linux'];
  }

  @override
  PlatformType get platform => PlatformType.linux;

  factory LinuxPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$LinuxPackageConfigFromJson(json);
}
