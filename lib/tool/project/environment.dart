import 'dart:convert';
import 'dart:io';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:jtech_base/jtech_base.dart';

// 环境安装包结果类型
typedef EnvironmentPackageResult = Map<String, List<EnvironmentPackageTuple>>;

// 已下载文件元组
typedef DownloadedFileTuple = ({List<String> downloaded, List<String> tmp});

// 已下载文件信息元组
typedef DownloadFileInfoTuple = ({int count, int totalSize});

// 环境安装包信息元组
typedef EnvironmentPackageTuple = ({
  String platform,
  String url,
  String fileName,
  String channel,
  String version,
  String dartVersion,
  String dartArch,
});

// 扩展环境安装包信息元组
extension EnvironmentPackageTupleExtension on EnvironmentPackageTuple {
  // 获取标题
  String get title => 'Flutter · $version · $channel';

  // 根据条件搜索判断是否符合要求
  bool search(String keyword) {
    if (keyword.isEmpty) return true;
    return title.contains(keyword) ||
        platform.contains(keyword) ||
        dartVersion.contains(keyword) ||
        dartArch.contains(keyword);
  }
}

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

  // 关键文件相对路径
  static const String _keyFilePath = 'bin/flutter';

  // 下载缓存目录
  static const String _downloadCachePath = 'download';

  // 获取环境信息
  static Future<Environment?> getEnvironmentInfo(String environmentPath) async {
    if (!isPathAvailable(environmentPath)) return null;
    // 执行flutter version命令并将结果格式化对象
    final output = await runEnvironmentCommand(environmentPath, ['--version']);
    if (output == null) return null;
    return Environment()
      ..path = environmentPath
      ..gitUrl = output.regFirstGroup(r'http.*\.git')
      ..version = output.regFirstGroup(r'Flutter (.*?) •', 1)
      ..channel = output.regFirstGroup(r'channel (.*?) •', 1)
      ..dartVersion = output.regFirstGroup(r'Dart (.*?) •', 1)
      ..devToolsVersion = output.regFirstGroup(r'DevTools(.*)', 1)
      ..frameworkReversion =
          output.regFirstGroup(r'Framework • revision (.*?) \(', 1)
      ..engineReversion = output.regFirstGroup(r'Engine • revision (.*)', 1)
      ..updatedAt =
          output.regFirstGroup(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} -\d{4}');
  }

  // 执行环境命令
  static Future<String?> runEnvironmentCommand(
      String environmentPath, List<String> arguments,
      {String? workingDirectory}) async {
    final result = await Process.run(
      join(environmentPath, _keyFilePath),
      arguments,
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) return null;
    return result.stdout.toString();
  }

  // 判断当前路径是否可用
  static bool isPathAvailable(String environmentPath) {
    final file = File(join(environmentPath, _keyFilePath));
    return file.existsSync();
  }

  // 获取当前平台的环境安装包列表
  static Future<EnvironmentPackageResult> getEnvironmentPackageList() async {
    final platform = Platform.operatingSystem;
    var json = localCache.getJson(_environmentPackageCacheKey);
    if (json == null) {
      final url = _environmentPackageInfoUrl.replaceAll('{platform}', platform);
      json = (await Dio().get(url)).data;
      await localCache.setJson(_environmentPackageCacheKey, json,
          expiration: const Duration(days: 1));
    }
    final result = <String, List<EnvironmentPackageTuple>>{};
    for (final e in json['releases'] ?? []) {
      final archive = e['archive'] ?? '';
      final package = (
        platform: platform,
        url: '${json['base_url']}/$archive',
        fileName: basename(archive),
        channel: '${e['channel']}',
        version: '${e['version']}',
        dartVersion: '${e['dart_sdk_version']}',
        dartArch: '${e['dart_sdk_arch']}',
      );
      final temp = result[package.channel] ?? [];
      result[package.channel] = temp..add(package);
    }
    return result;
  }

  // 下载环境安装包
  static Future<String?> downloadPackage(
    String url, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? onReceiveProgress,
  }) async {
    final baseDir = await getDownloadCachePath();
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
  static Future<DownloadFileInfoTuple> getDownloadFileInfo() async {
    final result = await getDownloadedFileList();
    final downloaded = result.downloaded;
    final tmp = result.tmp;
    final count = downloaded.length + tmp.length;
    final totalSize = downloaded.fold<int>(0, (previousValue, element) {
          return previousValue + File(element).lengthSync();
        }) +
        tmp.fold<int>(0, (previousValue, element) {
          return previousValue + File(element).lengthSync();
        });
    return (count: count, totalSize: totalSize);
  }

  // 获取已下载文件列表
  static Future<DownloadedFileTuple> getDownloadedFileList() async {
    final result = (downloaded: <String>[], tmp: <String>[]);
    final baseDir = await getDownloadCachePath();
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

  // 获取下载缓存目录
  static Future<String?> getDownloadCachePath() => FileTool.getDirPath(
        join(Common.baseCachePath, _downloadCachePath),
        root: FileDir.applicationDocuments,
      );

  // 获取默认的安装包目录
  static Future<String?> getDefaultInstallPath(
      EnvironmentPackageTuple package) async {
    final pathName = 'flutter_${package.version}'.replaceAll('.', '_');
    return FileTool.getDirPath(pathName, root: FileDir.applicationDocuments);
  }
}
