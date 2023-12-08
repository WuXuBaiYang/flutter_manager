import 'package:flutter_manager/tool/image.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// macos平台参数元组
typedef MacosPlatformInfoTuple = ();

/*
* macos平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class MacosPlatformTool extends PlatformTool {
  @override
  PlatformType get platform => PlatformType.macos;

  @override
  String get keyFilePath => 'Runner/Info.plist';

  // 图标资源路径
  final String _iconPath = 'Runner/Assets.xcassets/AppIcon.appiconset';

  // 图标信息文件相对路径
  late final String _iconInfoPath = '$_iconPath/Contents.json';

  // 读取图标信息文件信息
  Future<Map> _getIconInfoJson(String projectPath) =>
      readPlatformFileJson(projectPath, _iconInfoPath);

  @override
  Future<PlatformInfoTuple<MacosPlatformInfoTuple>?> getPlatformInfo(
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
    final document = await readPlatformFileXml(projectPath, keyFilePath);
    final items = document
        .getElement('plist')
        ?.getElement('dict')
        ?.childElements
        .where((e) => e.innerText == 'CFBundleName');
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
        .where((e) => e.innerText == 'CFBundleName');
    items?.firstOrNull?.nextElementSibling?.innerText = label;
    await writePlatformFileXml(projectPath, keyFilePath, fragment,
        indentAttribute: false);
    return true;
  }
}
