import 'platform.dart';

/*
* web平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:59
*/
class WebPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.web;

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
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final json = await _getManifestJson(projectPath);
    return {
      'favicon': getPlatformFilePath(projectPath, _faviconPath),
      ...(json['icons'] ?? []).asMap().map<String, dynamic>((_, item) {
        final src = item['src'];
        final entries = (item as Map)..removeWhere((_, value) => value == src);
        final key = entries.values.join('_');
        final value = getPlatformFilePath(projectPath, src);
        return MapEntry(key, value);
      })
    };
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
