import 'package:flutter_manager/tool/image.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// ios平台参数元组
typedef IosPlatformInfo = ();

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
  Future<PlatformInfo<IosPlatformInfo>?> getPlatformInfo(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformPath(projectPath),
      label: await getLabel(projectPath) ?? '',
      package: await getPackage(projectPath) ?? '',
      logos: await getLogos(projectPath) ?? [],
      permissions: await getPermissions(projectPath) ?? [],
      info: (),
    );
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final element = (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleDisplayName')
        .firstOrNull
        ?.nextElementSibling;
    if (element?.localName != 'string') return null;
    return element?.innerText;
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    final fragment = await _getPlistFragment(projectPath);
    final element = fragment
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleDisplayName')
        .firstOrNull
        ?.nextElementSibling
      ?..innerText = label;
    if (element?.localName != 'string') return false;
    return writePlatformFileXml(projectPath, keyFilePath, fragment,
        indentAttribute: false);
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

  @override
  Future<String?> getPackage(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final element = (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleIdentifier')
        .firstOrNull
        ?.nextElementSibling;
    if (element?.localName != 'string') return null;
    return element?.innerText;
  }

  @override
  Future<bool> setPackage(String projectPath, String package) async {
    if (!isPathAvailable(projectPath)) return false;
    final fragment = await _getPlistFragment(projectPath);
    final element = fragment
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleIdentifier')
        .firstOrNull
        ?.nextElementSibling
      ?..innerText = package;
    if (element?.localName != 'string') return false;
    return writePlatformFileXml(projectPath, keyFilePath, fragment,
        indentAttribute: false);
  }

  @override
  Future<List<PlatformPermission>?> getPermissions(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final permissions = (await _getPlistDocument(projectPath))
        .getElement('plist')
        ?.getElement('dict')
        ?.findElements('key');
    if (permissions == null) return null;
    final result = <PlatformPermission>[];
    for (PlatformPermission e in await getFullPermissions() ?? []) {
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
  Future<bool> setPermissions(
      String projectPath, List<PlatformPermission> permissions) async {
    if (!isPathAvailable(projectPath)) return false;
    final fragment = await _getPlistFragment(projectPath);
    final fullPermissions = (await getFullPermissions())?.map((e) => e.value);
    if (fullPermissions == null) return false;
    bool flag = false;
    fragment.getElement('plist')?.getElement('dict')?.children
      ?..removeWhere((e) {
        if (e is! XmlElement) return false;
        final key = e.localName;
        if (flag && key == 'string') return true;
        if (key == 'key') return flag = fullPermissions.contains(e.innerText);
        return flag = false;
      })
      ..addAll(permissions.expand((e) => [
            XmlElement(XmlName('key'), [], [XmlText(e.value)]),
            XmlElement(XmlName('string'), [], [XmlText(e.input)])
          ]));
    return writePlatformFileXml(projectPath, keyFilePath, fragment);
  }
}
