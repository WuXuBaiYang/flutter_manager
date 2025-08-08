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
  }) = _PackageConfig;

  // 获取打包脚本集合
  List<String> getScriptList() => [
    if (runPubGet) 'flutter pub get',
    if (runBuildRunner) 'dart run build_runner build',
  ];

  // 配置缓存key
  String getCacheKey() => throw UnimplementedError();

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
}) = _AndroidPackageConfig;

  @override
  List<String> getScriptList() {
    return [...super.getScriptList(), 'flutter build apk'];
  }

  @override
  String getCacheKey() => 'android';

  factory AndroidPackageConfig.fromJson(Map<String, dynamic> json) =>
      _$AndroidPackageConfigFromJson(json);
}
