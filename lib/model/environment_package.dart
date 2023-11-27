import 'package:flutter_manager/common/model.dart';

/*
* flutter环境安装包对象
* @author wuxubaiyang
* @Time 2023/11/25 20:39
*/
class EnvironmentPackage extends BaseModel {
  // 平台
  String platform = '';

  // 下载地址
  String url = '';

  // 文件名
  String fileName = '';

  // 构造函数
  String hash = '';

  // sha256
  String sha256 = '';

  // flutter分支
  String channel = '';

  // flutter版本
  String version = '';

  // dart版本
  String dartVersion = '';

  // dart架构
  String dartArch = '';

  // 发布日期
  String releaseDate = '';

  // 判断是否为开发稳定版
  bool get isStable => channel == 'stable';

  // 判断是否为开发测试版
  bool get isBeta => channel == 'beta';

  // 判断是否为开发版
  bool get isDev => channel == 'dev';

  EnvironmentPackage();

  EnvironmentPackage.from(obj)
      : platform = obj['platform'] ?? '',
        url = obj['url'] ?? '',
        fileName = obj['fileName'] ?? '',
        hash = obj['hash'] ?? '',
        sha256 = obj['sha256'] ?? '',
        channel = obj['channel'] ?? '',
        version = obj['version'] ?? '',
        dartVersion = obj['dartVersion'] ?? '',
        dartArch = obj['dartArch'] ?? '',
        releaseDate = obj['releaseDate'] ?? '';

  @override
  Map<String, dynamic> to() => {
        'platform': platform,
        'url': url,
        'fileName': fileName,
        'hash': hash,
        'sha256': sha256,
        'channel': channel,
        'version': version,
        'dartVersion': dartVersion,
        'dartArch': dartArch,
        'releaseDate': releaseDate,
      };
}
