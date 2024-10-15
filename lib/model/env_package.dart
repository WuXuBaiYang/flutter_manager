import 'package:jtech_base/jtech_base.dart';

/*
* flutter环境安装包
* @author wuxubaiyang
* @Time 2024/10/14 21:37
*/
class EnvironmentPackage extends BaseModel {
  // 下载地址
  final String url;

  // 文件名
  final String fileName;

  // 渠道
  final String channel;

  // 版本
  final String version;

  // dart版本
  final String dartVersion;

  // dart架构
  final String dartArch;

  // 部署路径
  final String? buildPath;

  // 已下载文件路径
  final String? downloadPath;

  // 已下载临时文件路径
  final String? tempPath;

  EnvironmentPackage({
    required this.url,
    required this.fileName,
    required this.channel,
    required this.version,
    required this.dartVersion,
    required this.dartArch,
    this.tempPath,
    this.buildPath,
    this.downloadPath,
  });

  EnvironmentPackage.from(
    obj, {
    required String baseUrl,
    this.tempPath,
    this.buildPath,
    String? fileName,
    this.downloadPath,
  })  : fileName = fileName ?? basename(obj?['archive'] ?? ''),
        url = '$baseUrl/${obj?['archive'] ?? ''}',
        channel = obj?['channel'] ?? '',
        version = obj?['version'] ?? '',
        dartVersion = obj?['dart_sdk_version'] ?? '',
        dartArch = obj?['dart_sdk_arch'] ?? '';

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

  @override
  EnvironmentPackage copyWith({
    String? url,
    String? fileName,
    String? channel,
    String? version,
    String? dartVersion,
    String? dartArch,
    String? downloadPath,
    String? buildPath,
    String? tempPath,
  }) {
    return EnvironmentPackage(
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      channel: channel ?? this.channel,
      version: version ?? this.version,
      dartVersion: dartVersion ?? this.dartVersion,
      dartArch: dartArch ?? this.dartArch,
      downloadPath: downloadPath ?? this.downloadPath,
      buildPath: buildPath ?? this.buildPath,
      tempPath: tempPath ?? this.tempPath,
    );
  }
}
