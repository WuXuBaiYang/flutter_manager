import 'package:flutter_manager/tool/image.dart';

import 'platform.dart';

// web平台参数元组
typedef WebPlatformInfoTuple = ({
  String path,
  String label,
  List<PlatformLogoTuple> logo,
});

/*
* web平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class WebPlatformTool extends PlatformTool {
  @override
  PlatformType get platform => PlatformType.web;

  @override
  String get keyFilePath => 'index.html';

  // manifest.json相对路径
  final String _manifestPath = 'manifest.json';

  // favicon.ico相对路径
  final String _faviconPath = 'favicon.png';

  // 读取manifest文件信息
  Future<Map> _getManifestJson(String projectPath) =>
      readPlatformFileJson(projectPath, _manifestPath);

  @override
  Future<Record?> getPlatformInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformType(projectPath),
      label: await getLabel(projectPath) ?? '',
      logo: await getLogoInfo(projectPath) ?? [],
    );
  }

  @override
  Future<List<PlatformLogoTuple>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getManifestJson(projectPath);
    final faviconSize =
        await ImageTool.getSize(getPlatformFilePath(projectPath, _faviconPath));
    final result = <PlatformLogoTuple>[
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
}
