import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/environment_package.dart';

/*
* 环境工具
* @author wuxubaiyang
* @Time 2023/11/25 20:30
*/
class EnvironmentTool {
  // 环境安装包信息接口地址
  static const String _environmentPackageInfoUrl =
      'https://storage.flutter-io.cn/flutter_infra_release/releases/releases_{platform}.json';

  // 获取环境信息
  static Future<Environment?> getEnvironmentInfo(String path) async {}

  // 获取当前平台的环境安装包列表
  static Future<
      ({
        List<EnvironmentPackage> beta,
        List<EnvironmentPackage> dev,
        List<EnvironmentPackage> stable
      })> getEnvironmentPackageList() async {
    final platform = Platform.operatingSystem;
    final url = _environmentPackageInfoUrl.replaceAll('{platform}', platform);
    final resp = await Dio().get(url);
    if (resp.statusCode != 200) throw Exception('获取环境安装包列表失败');
    final result = resp.data;
    final baseUrl = result['base_url'];
    final List<EnvironmentPackage> stable = [], beta = [], dev = [];
    for (final e in result['releases'] ?? []) {
      final package = EnvironmentPackage()
        ..platform = platform
        ..url = '$baseUrl/${e['archive'] ?? ''}'
        ..hash = e['hash'] ?? ''
        ..sha256 = e['sha256'] ?? ''
        ..channel = e['channel'] ?? ''
        ..version = e['version'] ?? ''
        ..dartVersion = e['dart_sdk_version'] ?? ''
        ..dartArch = e['dart_sdk_arch'] ?? ''
        ..releaseDate = e['release_date'] ?? '';
      if (package.isStable) stable.add(package);
      if (package.isBeta) beta.add(package);
      if (package.isDev) dev.add(package);
    }
    return (stable: stable, beta: beta, dev: dev);
  }
}
