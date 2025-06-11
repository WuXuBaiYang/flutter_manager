import 'dart:io';

import 'package:flutter_manager/tool/image.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// macos平台参数元组
typedef MacosPlatformInfo = ();

/*
* macos平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class MacosPlatformTool extends PlatformTool {
  // macos信息配置文件
  final String _infoPlistPath = 'Runner/Info.plist';

  // 图标资源路径
  final String _iconPath = 'Runner/Assets.xcassets/AppIcon.appiconset';

  // 图标信息文件相对路径
  late final String _iconInfoPath = '$_iconPath/Contents.json';

  // 读取plist文件信息
  Future<XmlDocument> _getPlistDocument(String projectPath) =>
      readPlatformFileXml(projectPath, _infoPlistPath);

  // 获取plist文件fragment
  Future<XmlDocumentFragment> _getPlistFragment(String projectPath) =>
      readPlatformFileXmlFragment(projectPath, _infoPlistPath);

  // 读取图标信息文件信息
  Future<Map> _getIconInfoJson(String projectPath) =>
      readPlatformFileJson(projectPath, _iconInfoPath);

  @override
  PlatformType get platform => PlatformType.macos;

  @override
  bool isPathAvailable(String projectPath) =>
      File(join(getPlatformPath(projectPath), _infoPlistPath)).existsSync();

  @override
  Future<PlatformInfo<MacosPlatformInfo>?> getPlatformInfo(
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
    return (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleName')
        .firstOrNull
        ?.nextElementSibling
        ?.innerText;
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    return writePlatformFileXml(
      projectPath,
      _infoPlistPath,
      (await _getPlistFragment(projectPath))
        ..getElement('plist')
            ?.getElement('dict')
            ?.childElements
            .where((e) => e.innerText == 'CFBundleName')
            .firstOrNull
            ?.nextElementSibling
            ?.innerText = label,
      indentAttribute: false,
    );
  }

  @override
  Future<List<PlatformLogo>?> getLogos(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getIconInfoJson(projectPath);
    final resPath = getPlatformFilePath(projectPath, _iconPath);
    final result = <PlatformLogo>[];
    for (final item in json['images'] ?? []) {
      final filename = item['filename'];
      final entries = (item as Map)
        ..removeWhere((_, value) => value == filename);
      final name = entries.values.join('_');
      final path = join(resPath, filename);
      final size = await ImageTool.getSize(path);
      if (size == null) continue;
      result.add((name: name, path: path, size: size));
    }
    return result;
  }
}
