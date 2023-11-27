import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/environment_package.dart';
import 'package:flutter_manager/tool/download.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:path/path.dart';

// 已下载文件元组
typedef DownloadedFileTuple = ({List<String> downloaded, List<String> tmp});

// 环境安装包结果类型
typedef EnvironmentPackageResult = Map<String, List<EnvironmentPackage>>;

/*
* 环境管理工具
* @author wuxubaiyang
* @Time 2023/11/25 20:30
*/
class EnvironmentTool {
  // 缓存环境安装包字段
  static const String _environmentPackageCacheKey = 'environmentPackage';

  // 环境安装包信息接口地址
  static const String _environmentPackageInfoUrl =
      'https://storage.flutter-io.cn/flutter_infra_release/releases/releases_{platform}.json';

  // 可执行文件相对路径
  static const String _executablePath = 'bin/flutter';

  // 下载缓存目录
  static const String _downloadCachePath = 'download';

  // 环境信息匹配正则表
  static final Map<RegExp, Map<String, dynamic> Function(String output)>
      _environmentRegMap = {
    RegExp(r'Flutter.*'): (output) {
      final items = output.split('•');
      return {
        'version': items[0].replaceAll('Flutter', '').trim(),
        'channel': items[1].replaceAll('channel', '').trim(),
        'gitUrl': items[2].trim(),
      };
    },
    RegExp(r'Framework.*'): (output) {
      final items = output.split('•');
      return {
        'frameworkReversion': items[1]
            .replaceAll('revision', '')
            .replaceAll(RegExp(r'\(.*\)'), '')
            .trim(),
        'updatedAt': items[2].trim(),
      };
    },
    RegExp(r'Engine.*'): (output) {
      final items = output.split('•');
      return {
        'engineReversion': items[1].replaceAll('revision', '').trim(),
      };
    },
    RegExp(r'Tools.*'): (output) {
      final items = output.split('•');
      return {
        'dartVersion': items[1].replaceAll('Dart', '').trim(),
        'devToolsVersion':
            items.length > 2 ? items[2].replaceAll('version', '').trim() : '',
      };
    },
  };

  // 获取环境信息
  static Future<Environment?> getEnvironmentInfo(String path) async {
    if (!isPathAvailable(path)) return null;
    // 执行flutter version命令并将结果格式化对象
    final result = await Process.run(
      join(path, _executablePath),
      ['--version'],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) return null;
    final output = result.stdout.toString();
    final json = _environmentRegMap
        .map((reg, fun) {
          final match = reg.stringMatch(output);
          if (match == null) throw Exception('匹配失败');
          return MapEntry(reg, fun(match));
        })
        .values
        .reduce((result, e) => result..addAll(e));
    return Environment.from(json)..path = path;
  }

  // 判断当前路径是否可用
  static bool isPathAvailable(String path) {
    final file = File(join(path, _executablePath));
    return file.existsSync();
  }

  // 获取当前平台的环境安装包列表
  static Future<EnvironmentPackageResult> getEnvironmentPackageList() async {
    final json = cache.getJson(_environmentPackageCacheKey);
    if (json != null) {
      return json.map<String, List<EnvironmentPackage>>((key, value) {
        return MapEntry<String, List<EnvironmentPackage>>(key,
            value.map<EnvironmentPackage>(EnvironmentPackage.from).toList());
      });
    }
    final platform = Platform.operatingSystem;
    final url = _environmentPackageInfoUrl.replaceAll('{platform}', platform);
    final resp = await Dio().get(url);
    if (resp.statusCode != 200) throw Exception('获取环境安装包列表失败');
    final baseUrl = resp.data['base_url'];
    final result = <String, List<EnvironmentPackage>>{};
    for (final e in resp.data['releases'] ?? []) {
      final archive = e['archive'] ?? '';
      final package = EnvironmentPackage()
        ..platform = platform
        ..url = '$baseUrl/$archive'
        ..fileName = basename(archive)
        ..hash = e['hash'] ?? ''
        ..sha256 = e['sha256'] ?? ''
        ..channel = e['channel'] ?? ''
        ..version = e['version'] ?? ''
        ..dartVersion = e['dart_sdk_version'] ?? ''
        ..dartArch = e['dart_sdk_arch'] ?? ''
        ..releaseDate = e['release_date'] ?? '';
      final temp = result[package.channel] ?? [];
      result[package.channel] = temp..add(package);
    }
    await cache.setJson(_environmentPackageCacheKey, result.map((key, value) {
      final temp = value.map((e) => e.to()).toList();
      return MapEntry(key, temp);
    }));
    return result;
  }

  // 下载环境安装包
  static Future<String?> downloadPackage(
    String url, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? onReceiveProgress,
  }) async {
    final baseDir = await _getDownloadCachePath();
    if (baseDir == null) throw Exception('获取下载目录失败');
    final savePath = join(baseDir, basename(url));
    if (File(savePath).existsSync()) return savePath;
    final tempPath = await Downloader.start(
      url,
      '$savePath.tmp',
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    if (tempPath == null) throw Exception('下载文件失败');
    return tempPath.renameSync(savePath).path;
  }

  // 获取已下载文件列表
  static Future<DownloadedFileTuple> getDownloadedFileList() async {
    final result = (downloaded: <String>[], tmp: <String>[]);
    final baseDir = await _getDownloadCachePath();
    if (baseDir == null) return result;
    final dir = Directory(baseDir);
    if (!dir.existsSync()) return result;
    dir.listSync().forEach((e) {
      final path = e.path;
      if (path.contains('.tmp')) {
        result.tmp.add(path);
      } else {
        result.downloaded.add(path);
      }
    });
    return result;
  }

  // 获取默认的安装包目录
  static Future<String?> getDefaultInstallPath(
      EnvironmentPackage package) async {
    final pathName = 'flutter_${package.version}'.replaceAll('.', '_');
    return FileTool.getDirPath(pathName, root: FileDir.applicationDocuments);
  }

  // 获取下载缓存目录
  static Future<String?> _getDownloadCachePath() => FileTool.getDirPath(
        join(Common.baseCachePath, _downloadCachePath),
        root: FileDir.applicationDocuments,
      );
}
