import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jtech_base/jtech_base.dart';

part 'env_package.g.dart';

part 'env_package.freezed.dart';

// flutter环境安装包
@freezed
abstract class EnvPackage with _$EnvPackage {
  const EnvPackage._();

  const factory EnvPackage({
    required String url,
    required String fileName,
    required String channel,
    required String version,
    required String dartVersion,
    required String dartArch,
    String? buildPath,
    String? downloadPath,
    String? tempPath,
  }) = _EnvPackage;

  factory EnvPackage.fromJson(Map<String, dynamic> json) =>
      _$EnvPackageFromJson(json);

  static EnvPackage create(
    Map<String, dynamic> json, {
    required String baseUrl,
    String? fileName,
    String? tempPath,
    String? buildPath,
    String? downloadPath,
  }) {
    return EnvPackage(
      url: '$baseUrl/${json['archive'] ?? ''}',
      fileName: fileName ?? basename(json['archive'] ?? ''),
      channel: json['channel'] ?? '',
      version: json['version'] ?? '',
      dartVersion: json['dart_sdk_version'] ?? '',
      dartArch: json['dart_sdk_arch'] ?? '',
    );
  }

  // 判断当前是否满足导入条件（包含部署地址与安装包地址）
  bool get canImport => buildPath != null && downloadPath != null;

  // 判断是否存在已下载文件路径
  bool get hasDownload => downloadPath != null;

  // 判断是否存在已下载临时文件路径
  bool get hasTemp => tempPath != null;

  // 获取标题
  String get title => 'Flutter · $version · $channel';

  // 根据条件搜索判断是否符合要求
  bool search(String keyword) {
    if (keyword.isEmpty) return true;
    return title.contains(keyword) ||
        dartVersion.contains(keyword) ||
        dartArch.contains(keyword);
  }
}
