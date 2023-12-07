import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';

/*
* 图片处理工具
* @author wuxubaiyang
* @Time 2023/12/6 8:51
*/
class ImageTool {
  // 获取图片尺寸
  static Future<Size?> getSize(String path) async {
    final image = (await getInfo(path))?.image;
    if (image == null) return null;
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  // 获取图片信息
  static Future<ImageInfo?> getInfo(String path) {
    final c = Completer<ImageInfo?>();
    FileImage(File(path))
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) => c.complete(info)));
    return c.future;
  }

  // 修改图片尺寸并保存
  static Future<String?> resizeFile(String path, String savePath,
      {ImageType imageType = ImageType.png, int? width, int? height}) async {
    try {
      await _executeCommand(
        Command()
          ..decodeImageFile(path)
          ..copyResize(width: width, height: height),
        savePath,
        imageType,
      );
    } catch (_) {}
    return null;
  }

  // 格式化图片并保存
  static Future<String?> saveData(Uint8List data, String savePath,
      [ImageType imageType = ImageType.png]) async {
    try {
      await _executeCommand(
        Command()..decodeImage(data),
        savePath,
        imageType,
      );
      return savePath;
    } catch (_) {}
    return null;
  }

  // 执行命令
  static Future<Command> _executeCommand(Command cmd, String savePath,
      [ImageType imageType = ImageType.png]) {
    switch (imageType) {
      case ImageType.png:
        cmd = cmd..encodePngFile(savePath);
      case ImageType.jpg:
        cmd = cmd..encodeJpgFile(savePath);
      case ImageType.ico:
        cmd = cmd..encodeIcoFile(savePath);
    }
    return cmd.executeThread();
  }
}

// 图片格式枚举
enum ImageType { png, jpg, ico }
