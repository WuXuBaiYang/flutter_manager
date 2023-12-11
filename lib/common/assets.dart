import 'dart:io';
import 'package:flutter_manager/tool/project/platform/platform.dart';

/*
* 静态资源/通用静态变量
* @author wuxubaiyang
* @Time 2023/11/21 15:46
*/
class Assets {
  // 根据平台获取权限列表
  static String getPermission(PlatformType platform) =>
      'assets/permission/${platform.name}.json';
}
