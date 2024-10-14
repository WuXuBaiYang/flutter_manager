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

  EnvironmentPackage.from(obj)
      : url = '${obj?['base_url'] ?? ''}/${obj?['archive'] ?? ''}',
        fileName = basename(obj?['archive'] ?? ''),
        channel = obj?['channel'] ?? '',
        version = obj?['version'] ?? '',
        dartVersion = obj?['dart_sdk_version'] ?? '',
        dartArch = obj?['dart_sdk_arch'] ?? '';

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
