import 'dart:convert';
import 'dart:io';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/model/env_package.dart';
import 'package:flutter_manager/tool/download.dart';
import 'package:jtech_base/jtech_base.dart';

// 已下载文件元组
typedef DownloadEnvResult = ({List<String> downloaded, List<String> tmp});

// 已下载文件信息元组
typedef DownloadEnvInfo = ({int count, int totalFileSize});

/*
* 环境管理工具
* @author wuxubaiyang
* @Time 2023/11/25 20:30
*/
class EnvironmentTool {
  // 缓存环境安装包字段
  static const String _envPackageCacheKey = 'envPackageCache';

  // 环境安装包信息接口地址
  static const String _envPackageInfoUrl =
      'https://storage.flutter-io.cn/flutter_infra_release/releases/releases_{platform}.json';

  // 关键文件相对路径
  static const String _keyFilePath = 'bin/flutter';

  // 判断当前路径是否可用
  static bool isAvailable(String? path) {
    if (path == null) return false;
    final file = File(join(path, _keyFilePath));
    return file.existsSync();
  }

  // 执行环境命令
  static Future<String?> runCommand(
    String path,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    final result = await Process.run(
      join(path, _keyFilePath),
      arguments,
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) return null;
    return result.stdout.toString();
  }

  // 获取环境信息
  static Future<Environment?> getInfo(String path) async {
    if (!isAvailable(path)) return null;
    // 执行flutter version命令并将结果格式化对象
    final result = await runCommand(path, ['--version']);
    if (result == null) return null;
    return Environment.create(
      path: path,
      gitUrl: result.regFirstGroup(r'http.*\.git'),
      version: result.regFirstGroup(r'Flutter (.*?) •', 1),
      channel: result.regFirstGroup(r'channel (.*?) •', 1),
      dartVersion: result.regFirstGroup(r'Dart (.*?) •', 1),
      devToolsVersion: result.regFirstGroup(r'DevTools(.*)', 1),
      frameworkReversion:
          result.regFirstGroup(r'Framework • revision (.*?) \(', 1),
      engineReversion: result.regFirstGroup(r'Engine • revision (.*)', 1),
      updateTime:
          result.regFirstGroup(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} -\d{4}'),
    );
  }

  // 获取当前平台的环境安装包列表
  static Future<Map<String, List<EnvironmentPackage>>>
      getChannelPackages() async {
    var json = localCache.getJson(_envPackageCacheKey);
    if (json == null) {
      final url = _envPackageInfoUrl.replaceAll(
        '{platform}',
        Platform.operatingSystem,
      );
      json = (await Dio().get(url)).data;
      await localCache.setJson(_envPackageCacheKey, json,
          expiration: const Duration(days: 1));
    }
    return List<EnvironmentPackage>.from(
      (json['releases'] ?? []).map(EnvironmentPackage.from),
    ).groupBy<String>((e) => e.channel);
  }

  // 下载环境安装包
  static Future<String?> download(
    String url, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? onReceiveProgress,
  }) async {
    final baseDir = await Tool.getCacheFilePath();
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

  // 获取已下载文件信息
  static Future<DownloadEnvInfo> getDownloadInfo() async {
    final result = await getDownloadResult();
    final tmp = result.tmp;
    final downloaded = result.downloaded;
    final count = downloaded.length + tmp.length;
    final totalFileSize =
        downloaded.fold<int>(0, (p, e) => p + File(e).lengthSync()) +
            tmp.fold<int>(0, (p, e) => p + File(e).lengthSync());
    return (count: count, totalFileSize: totalFileSize);
  }

  // 获取已下载文件列表
  static Future<DownloadEnvResult> getDownloadResult() async {
    final result = (downloaded: <String>[], tmp: <String>[]);
    final baseDir = await Tool.getCacheFilePath();
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
  static Future<String?> getInstallPath(EnvironmentPackage package) async {
    final pathName = 'flutter_${package.version}'.replaceAll('.', '_');
    return FileTool.getDirPath(pathName, root: FileDir.applicationDocuments);
  }
}
