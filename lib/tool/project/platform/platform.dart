import 'dart:io';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;

/*
* 平台工具抽象类
* @author wuxubaiyang
* @Time 2023/11/29 18:37
*/
abstract class PlatformTool with PlatformToolMixin {
  // 平台文件夹路径
  PlatformPath get platform;

  // 关键文件相对路径
  String get keyFilePath;

  // 获取平台文件夹路径
  String get platformPath => platform.name;

  // 判断当前路径是否可用
  bool isPathAvailable(String projectPath) =>
      File(join(getPlatformPath(projectPath), keyFilePath)).existsSync();

  // 获取平台路径
  String getPlatformPath(String projectPath) => join(projectPath, platformPath);

  // 获取logo
  @override
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return {};
  }

  // 替换logo
  @override
  Future<bool> replaceLogo(String projectPath, String logoPath) async {
    final logoMap = await getLogoInfo(projectPath);
    if (logoMap == null) return false;
    // 遍历图片表，读取原图片信息并将输入logo替换为目标图片
    for (final item in logoMap.entries) {
      final source = await img.decodeImageFile(item.value);
      if (source == null) continue;
      final suffixes = basename(item.value).split('.').lastOrNull;
      if (suffixes?.isEmpty ?? true) continue;
      var cmd = img.Command()
        ..decodeImageFile(logoPath)
        ..copyResize(width: source.width, height: source.height);
      if (suffixes == 'png') cmd = cmd..encodePng();
      if (suffixes == 'jpg') cmd = cmd..encodeJpg();
      if (suffixes == 'ico') cmd = cmd..encodeIco();
      await (cmd..writeToFile(item.value)).executeThread();
    }
    return true;
  }
}

/*
* 平台工具抽象类方法
* @author wuxubaiyang
* @Time 2023/11/29 20:13
*/
abstract mixin class PlatformToolMixin {
  // 获取logo
  Future<Map<String, dynamic>?> getLogoInfo(String projectPath);

  // 替换logo
  Future<bool> replaceLogo(String projectPath, String logoPath);
}

/*
* 支持平台枚举
* @author wuxubaiyang
* @Time 2023/11/29 18:58
*/
enum PlatformPath {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}
