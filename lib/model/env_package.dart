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

  // 已下载文件路径
  final String? savePath;

  // 已下载临时文件路径
  final String? tempPath;

  EnvironmentPackage({
    required this.url,
    required this.fileName,
    required this.channel,
    required this.version,
    required this.dartVersion,
    required this.dartArch,
    this.savePath,
    this.tempPath,
  });

  EnvironmentPackage.from(obj, {String? fileName, this.savePath, this.tempPath})
      : fileName = fileName ?? basename(obj?['archive'] ?? ''),
        url = '${obj?['base_url'] ?? ''}/${obj?['archive'] ?? ''}',
        channel = obj?['channel'] ?? '',
        version = obj?['version'] ?? '',
        dartVersion = obj?['dart_sdk_version'] ?? '',
        dartArch = obj?['dart_sdk_arch'] ?? '';

  // 判断是否存在已下载文件路径
  bool get hasSavePath => savePath != null;

  // 判断是否存在已下载临时文件路径
  bool get hasTempPath => tempPath != null;

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
    String? savePath,
    String? tempPath,
  }) {
    return EnvironmentPackage(
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      channel: channel ?? this.channel,
      version: version ?? this.version,
      dartVersion: dartVersion ?? this.dartVersion,
      dartArch: dartArch ?? this.dartArch,
      savePath: savePath ?? this.savePath,
      tempPath: tempPath ?? this.tempPath,
    );
  }
}
