import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/ios.dart';
import 'package:flutter_manager/tool/project/platform/linux.dart';
import 'package:flutter_manager/tool/project/platform/macos.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/platform/web.dart';
import 'package:flutter_manager/tool/project/platform/windows.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';

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

  // 平台工具对照表
  static final Map<PlatformType, PlatformTool> _platformTools = {
    PlatformType.android: AndroidPlatformTool(),
    PlatformType.ios: IosPlatformTool(),
    PlatformType.web: WebPlatformTool(),
    PlatformType.windows: WindowsPlatformTool(),
    PlatformType.macos: MacosPlatformTool(),
    PlatformType.linux: LinuxPlatformTool(),
  };

  // 创建项目平台
  static Future<bool> createPlatform(
      Project project, PlatformType platform) async {
    final environment = await database.getEnvironmentById(project.envId);
    if (environment == null) return false;
    final output = await EnvironmentTool.runEnvironmentCommand(
        environment.path, ['create', '--platforms', platform.name, '.'],
        workingDirectory: project.path);
    if (output == null) return false;
    return hasPlatform(platform, project.path);
  }

  // 移除项目平台
  static Future<bool> removePlatform(
      Project project, PlatformType platform) async {
    await FileTool.clearDir(join(project.path, platform.name));
    return !hasPlatform(platform, project.path);
  }

  // 获取项目详情页平台排序
  static List<PlatformType> getPlatformSort() {
    getSort(String key) => cache
        .getJson<List>(key)
        ?.map<PlatformType>((e) => PlatformType.values[e as int])
        .toList();
    return getSort(_platformSortKey) ?? PlatformType.values;
  }

  // 缓存项目详情页平台排序
  static Future<bool> cachePlatformSort(List<PlatformType> platforms) async {
    final values = platforms.map<int>((e) => e.index).toList();
    return cache.setJson(_platformSortKey, values);
  }

  // 判断是否存在该平台
  static bool hasPlatform(PlatformType platform, String projectPath) =>
      _platformTools[platform]!.isPathAvailable(projectPath);

  // 获取当前项目支持的平台数量
  static List<PlatformType> getPlatforms(String projectPath) {
    final entries = [..._platformTools.entries]
      ..removeWhere((e) => !e.value.isPathAvailable(projectPath));
    return entries.map<PlatformType>((e) => e.key).toList();
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

  // 获取项目图标
  static Future<String?> getProjectLogo(String projectPath,
      {double minSize = 50}) async {
    for (final tool in _platformTools.values) {
      final result = await tool.getLogoInfo(projectPath);
      if (result == null) continue;
      // 遍历结果找到合适尺寸的图片返回
      for (final item in result) {
        final src = await decodeImageFile(item.path);
        final imageSize = min(src?.width ?? 0, src?.height ?? 0);
        if (imageSize >= minSize) return item.path;
      }
    }
    return null;
  }

  // 获取平台信息
  static Future<T?> getPlatformInfo<T extends Record>(
      PlatformType platform, String projectPath) async {
    final tool = getPlatformTool(platform);
    return await tool.getPlatformInfo(projectPath) as T?;
  }

  // 根据传入平台获取对应的平台工具
  static T getPlatformTool<T extends PlatformTool>(PlatformType platform) =>
      _platformTools[platform]! as T;

  // 根据平台获取图标
  static Future<List<PlatformLogoTuple>?> getLogoInfo(
          PlatformType platform, String projectPath) =>
      getPlatformTool(platform).getLogoInfo(projectPath);

  // 根据平台替换图标
  static Future<bool> replaceLogo(
          PlatformType platform, String projectPath, String logoPath,
          {ProgressCallback? progressCallback}) =>
      getPlatformTool(platform).replaceLogo(projectPath, logoPath,
          progressCallback: progressCallback);

  // 根据平台获取项目名
  static Future<String?> getLabel(PlatformType platform, String projectPath) =>
      getPlatformTool(platform).getLabel(projectPath);

  // 根据平台设置项目名
  static Future<bool> setLabel(
          PlatformType platform, String projectPath, String label) =>
      getPlatformTool(platform).setLabel(projectPath, label);
}
