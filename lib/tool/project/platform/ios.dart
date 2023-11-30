import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
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
  Future<String> _getIconInfo(String projectPath) async {
    final file = File(join(getPlatformPath(projectPath), _iconInfoPath));
    return file.readAsStringSync();
  }

  // 获取logo
  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final content = jsonDecode(await _getIconInfo(projectPath));
    final resPath = join(getPlatformPath(projectPath), _iconPath);
    return (content['images'] ?? []).asMap().map<String, dynamic>((_, item) {
      final key = '${item['idiom']}_${item['size']}@${item['scale']}';
      return MapEntry(key, join(resPath, item['filename']));
    });
  }
}
