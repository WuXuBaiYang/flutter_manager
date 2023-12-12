import 'package:flutter_manager/tool/image.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// ios平台参数元组
typedef IosPlatformInfoTuple = ();

/*
* ios平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:58
*/
class IosPlatformTool extends PlatformTool {
  @override
  PlatformType get platform => PlatformType.ios;

  @override
  String keyFilePath = 'Runner/Info.plist';

  // 图标资源路径
  final String _iconPath = 'Runner/Assets.xcassets/AppIcon.appiconset';

  // 图标信息文件相对路径
  late final String _iconInfoPath = '$_iconPath/Contents.json';

  // 读取plist文件信息
  Future<XmlDocument> _getPlistDocument(String projectPath) =>
      readPlatformFileXml(projectPath, keyFilePath);

  // 获取plist文件fragment
  Future<XmlDocumentFragment> _getPlistFragment(String projectPath) =>
      readPlatformFileXmlFragment(projectPath, keyFilePath);

  // 读取图标信息文件信息
  Future<Map> _getIconInfoJson(String projectPath) =>
      readPlatformFileJson(projectPath, _iconInfoPath);

  @override
  Future<PlatformInfoTuple<IosPlatformInfoTuple>?> getPlatformInfo(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformType(projectPath),
      label: await getLabel(projectPath) ?? '',
      logos: await getLogoInfo(projectPath) ?? [],
      info: (),
    );
  }

  @override
  Future<List<PlatformLogoTuple>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getIconInfoJson(projectPath);
    final resPath = getPlatformFilePath(projectPath, _iconPath);
    final result = <PlatformLogoTuple>[];
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

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final items = (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleDisplayName');
    return items?.firstOrNull?.nextElementSibling?.innerText;
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    return writePlatformFileXml(
      projectPath,
      keyFilePath,
      (await _getPlistFragment(projectPath))
        ..getElement('plist')
            ?.getElement('dict')
            ?.childElements
            .where((e) => e.innerText == 'CFBundleDisplayName')
            .firstOrNull
            ?.nextElementSibling
            ?.innerText = label,
      indentAttribute: false,
    );
  }

  @override
  Future<List<PlatformPermissionTuple>?> getPermissionList(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final permissions = (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.findElements('key');
    if (permissions == null) return null;
    final result = <PlatformPermissionTuple>[];
    for (PlatformPermissionTuple e in await getFullPermissionList() ?? []) {
      final element = permissions.where((it) {
        return it.innerText == e.value;
      }).firstOrNull;
      if (element == null) continue;
      final nextElement = element.nextElementSibling;
      if (nextElement?.localName == 'string') {
        e = e.copyWith(input: nextElement?.innerText);
      }
      result.add(e);
    }
    return result;
  }

  @override
  Future<bool> setPermissionList(
      String projectPath, List<PlatformPermissionTuple> permissions) async {
    if (!isPathAvailable(projectPath)) return false;
    return true;
  }
}
