import 'dart:io';
import 'package:flutter_manager/tool/tool.dart';
import 'package:path/path.dart';
import 'platform.dart';

/*
* Android平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:55
*/
class AndroidPlatformTool extends PlatformTool {
  @override
  PlatformPath get platform => PlatformPath.android;

  @override
  String keyFilePath = 'build.gradle';

  // manifest相对路径
  final String _manifestPath = 'app/src/main/AndroidManifest.xml';

  // 资源目录
  final String _resPath = 'app/src/main/res';

  // 读取manifest文件信息
  Future<String> _getManifestInfo(String projectPath) async {
    final file = File(join(getPlatformPath(projectPath), _manifestPath));
    return file.readAsStringSync();
  }

  // 获取logo
  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    // 从manifest中获取logo的路径信息
    final content = await _getManifestInfo(projectPath);
    final iconPath = content.regFirstGroup(r'android:icon="@(.*)"', 1);
    // 遍历res下所有文件并过滤出目标图片
    final parentKey = iconPath.split('/').first;
    final iconRegExp = RegExp(iconPath.replaceAll('/', '|'));
    final dir = Directory(join(getPlatformPath(projectPath), _resPath));
    // 移除不符合条件的文件
    final files = dir.listSync(recursive: true)
      ..removeWhere((e) {
        return !e.path.contains(iconRegExp) ||
            !e.parent.path.contains(parentKey);
      });
    // 将符合条件的文件转换为指定格式的map<图片清晰度，图片路径>
    return files.asMap().map<String, dynamic>((_, e) {
      final path = e.parent.path;
      final index = path.lastIndexOf('-');
      final key = path.substring(index + 1);
      return MapEntry(key, e.path);
    });
  }
}
