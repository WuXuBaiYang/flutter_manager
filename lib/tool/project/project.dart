import 'dart:io';
import 'dart:math';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;

/*
* 项目管理工具
* @author wuxubaiyang
* @Time 2023/11/27 14:43
*/
class ProjectTool {
  // 项目详情页平台排序缓存key
  static const String _platformSortKey = 'platform_sort';

  // 关键文件相对路径
  static const String _keyFilePath = 'pubspec.yaml';

  // 匹配项目名称
  static final RegExp _projectNameReg = RegExp(r'name:.*');

  // 缓存路径
  static const String _cachePath = 'cache';

  // 平台工具对照表
  static final Map<PlatformPath, PlatformTool> _platformTools = {
    PlatformPath.android: AndroidPlatformTool(),
    PlatformPath.ios: IosPlatformTool(),
    PlatformPath.web: WebPlatformTool(),
    PlatformPath.windows: WindowsPlatformTool(),
    PlatformPath.macos: MacosPlatformTool(),
    PlatformPath.linux: LinuxPlatformTool(),
  };

  // 根据传入平台获取对应的平台工具
  static PlatformTool getPlatformTool(PlatformPath platform) =>
      _platformTools[platform]!;

  // 获取项目详情页平台排序
  static List<PlatformPath> getPlatformSort([Id? projectId]) {
    getSort(String key) => cache
        .getJson<List>(key)
        ?.map<PlatformPath>((e) => PlatformPath.values[e as int])
        .toList();
    getDefaultSort() => getSort(_platformSortKey) ?? PlatformPath.values;

    if (projectId == null) return getDefaultSort();
    return getSort('${_platformSortKey}_$projectId') ?? getDefaultSort();
  }

  // 缓存项目详情页平台排序
  static Future<bool> cachePlatformSort(List<PlatformPath> platforms,
      [Id? projectId]) async {
    final values = platforms.map<int>((e) => e.index).toList();
    final cacheKey =
        projectId != null ? '${_platformSortKey}_$projectId' : _platformSortKey;
    return cache.setJson(cacheKey, values);
  }

  // 获取项目信息
  static Future<Project?> getProjectInfo(String path) async {
    if (!isPathAvailable(path)) return null;
    return Project()
      ..path = path
      ..label = await ProjectTool.getProjectName(path) ?? ''
      ..logo = await ProjectTool.getProjectLogo(path) ?? '';
  }

  // 判断当前路径是否可用
  static bool isPathAvailable(String projectPath) {
    final file = File(join(projectPath, _keyFilePath));
    return file.existsSync();
  }

  // 读取项目名称
  static Future<String?> getProjectName(String projectPath) async {
    final file = File(join(projectPath, _keyFilePath));
    if (!file.existsSync()) return null;
    final content = await file.readAsString();
    final result = _projectNameReg.stringMatch(content);
    return result?.split(':').lastOrNull?.trim();
  }

  // 缓存目标文件到缓存目录
  static Future<String?> cacheFile(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) return null;
    final baseDir = await _getCachePath();
    if (baseDir == null) return null;
    final outputPath = join(baseDir, '${Tool.genID()}${file.suffixes}');
    return (await file.copy(outputPath)).path;
  }

  // 获取当前项目支持的平台数量
  static List<PlatformPath> getPlatforms(String projectPath) {
    final entries = [..._platformTools.entries]
      ..removeWhere((e) => !e.value.isPathAvailable(projectPath));
    return entries.map<PlatformPath>((e) => e.key).toList();
  }

  // 获取项目图标
  static Future<String?> getProjectLogo(String projectPath,
      {double minSize = 50}) async {
    for (final tool in _platformTools.values) {
      final result = await tool.getLogoInfo(projectPath);
      if (result == null) continue;
      // 遍历结果找到合适尺寸的图片返回
      for (final item in result.entries) {
        final source = await img.decodeImageFile(item.value);
        final imageSize = min(source?.width ?? 0, source?.height ?? 0);
        if (imageSize >= minSize) return item.value;
      }
    }
    return null;
  }

  // 根据平台获取图标
  static Future<Map<String, dynamic>?> getLogoInfo(
          PlatformPath platform, String projectPath) =>
      getPlatformTool(platform).getLogoInfo(projectPath);

  // 根据平台替换图标
  static Future<bool> replaceLogo(
          PlatformPath platform, String projectPath, String logoPath) =>
      getPlatformTool(platform).replaceLogo(projectPath, logoPath);

  // 根据平台获取项目名
  static Future<String?> getLabel(PlatformPath platform, String projectPath) =>
      getPlatformTool(platform).getLabel(projectPath);

  // 根据平台设置项目名
  static Future<bool> setLabel(
          PlatformPath platform, String projectPath, String label) =>
      getPlatformTool(platform).setLabel(projectPath, label);

  // 获取缓存目录
  static Future<String?> _getCachePath() => FileTool.getDirPath(
        join(Common.baseCachePath, _cachePath),
        root: FileDir.applicationDocuments,
      );
}
