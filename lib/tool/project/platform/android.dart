import 'dart:io';
import 'package:path/path.dart';

/*
* Android平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:55
*/
class AndroidPlatformTool {
  // 平台文件夹路径
  static String get platformPath => 'android';

  // 关键文件相对路径
  static const String _keyFilePath = 'build.gradle';

  // manifest相对路径
  static const String _manifestPath = 'app/src/main/AndroidManifest.xml';

  // 读取manifest文件信息
  static Future<String> _getManifestInfo(String projectPath) {
    final manifestFile =
        File(join(getPlatformPath(projectPath), _manifestPath));
    return manifestFile.readAsString();
  }

  // 获取logo
  static Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    // 从manifest中获取logo的路径信息android:icon="@mipmap/ic_launcher"
    final content = await _getManifestInfo(projectPath);
    final reg = RegExp(r'android:icon="@(.*)"');
    // 取出括号内的内容
    final iconPath = reg.firstMatch(content)?.group(1);
    if (iconPath == null) return null;
    return null;
  }

  // 替换logo
  static Future<bool> replaceLogo(String projectPath, String logoPath) async {
    return true;
  }

  // 判断当前路径是否可用
  static bool isPathAvailable(String projectPath) {
    final file = File(join(getPlatformPath(projectPath), _keyFilePath));
    return file.existsSync();
  }

  // 获取平台路径
  static String getPlatformPath(String projectPath) =>
      join(projectPath, platformPath);
}
