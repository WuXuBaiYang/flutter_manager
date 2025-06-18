import 'package:jtech_base/jtech_base.dart';

/*
* 静态资源/通用静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:54
*/
class Common {
  // 默认缓存名称
  static const String defaultCacheName = 'flutter_manager';

  // git下载地址
  static const String gitDownloadUrl = 'https://git-scm.com/downloads';

  // 模板项目地址
  static const String templateUrl =
      'https://github.com/WuXuBaiYang/jtech_base.git';

  // 模板项目名称
  static String get templateName =>
      basename(templateUrl).replaceAll('.git', '');

  // 模板创建脚本
  static const String templateCreateScript = 'create_project';
}
