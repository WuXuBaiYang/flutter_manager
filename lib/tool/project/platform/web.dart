import 'dart:io';

import 'package:flutter_manager/tool/image.dart';
import 'package:jtech_base/jtech_base.dart';
import 'platform.dart';

// web平台参数元组
typedef WebPlatformInfo = ();

/*
* web平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class WebPlatformTool extends PlatformTool {
  // 入口页路径
  final String _indexPath = 'index.html';

  // manifest.json相对路径
  final String _manifestPath = 'manifest.json';

  // favicon.ico相对路径
  final String _faviconPath = 'favicon.png';

  // 读取manifest文件信息
  Future<Map> _getManifestJson(String projectPath) =>
      readPlatformFileJson(projectPath, _manifestPath);

  @override
  PlatformType get platform => PlatformType.web;

  @override
  bool isPathAvailable(String projectPath) =>
      File(join(getPlatformPath(projectPath), _indexPath)).existsSync();

  @override
  Future<PlatformInfo<WebPlatformInfo>?> getPlatformInfo(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformPath(projectPath),
      label: await getLabel(projectPath) ?? '',
      package: await getPackage(projectPath) ?? '',
      logos: await getLogos(projectPath) ?? [],
      permissions: <PlatformPermission>[],
      info: (),
    );
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getManifestJson(projectPath);
    return json['name'];
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    final json = await _getManifestJson(projectPath);
    json['name'] = label;
    await writePlatformFileJson(projectPath, _manifestPath, json);
    return true;
  }

  @override
  Future<List<PlatformLogo>?> getLogos(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getManifestJson(projectPath);
    final faviconSize =
        await ImageTool.getSize(getPlatformFilePath(projectPath, _faviconPath));
    final result = <PlatformLogo>[
      if (faviconSize != null)
        (
          name: 'favicon',
          path: getPlatformFilePath(projectPath, _faviconPath),
          size: faviconSize,
        )
    ];
    for (final item in json['icons'] ?? []) {
      final src = item['src'];
      final entries = (item as Map)..removeWhere((_, value) => value == src);
      final name = entries.values.join('_');
      final path = getPlatformFilePath(projectPath, src);
      final size = await ImageTool.getSize(path);
      if (size == null) continue;
      result.add((name: name, path: path, size: size));
    }
    return result;
  }
}
