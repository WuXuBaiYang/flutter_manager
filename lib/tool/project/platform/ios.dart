import 'package:path/path.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

/*
* ios平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:58
*/
class IosPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.ios;

  @override
  String keyFilePath = 'Runner/Info.plist';

  // 图标资源路径
  final String _iconPath = 'Runner/Assets.xcassets/AppIcon.appiconset';

  // 图标信息文件相对路径
  late final String _iconInfoPath = '$_iconPath/Contents.json';

  // 读取图标信息文件信息
  Future<Map> _getIconInfoJson(String projectPath) =>
      readPlatformFileJson(projectPath, _iconInfoPath);

  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getIconInfoJson(projectPath);
    final resPath = getPlatformFilePath(projectPath, _iconPath);
    return (json['images'] ?? []).asMap().map<String, dynamic>((_, item) {
      final filename = item['filename'];
      final entries = (item as Map)
        ..removeWhere((_, value) => value == filename);
      final key = entries.values.join('_');
      final value = join(resPath, filename);
      return MapEntry(key, value);
    });
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final document = await readPlatformFileXml(projectPath, keyFilePath);
    final items = document
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleDisplayName');
    return items?.firstOrNull?.nextElementSibling?.innerText;
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    final fragment =
        await readPlatformFileXmlFragment(projectPath, keyFilePath);
    final items = fragment
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleDisplayName');
    items?.firstOrNull?.nextElementSibling?.innerText = label;
    await writePlatformFileXml(projectPath, keyFilePath, fragment,
        indentAttribute: false);
    return true;
  }
}
