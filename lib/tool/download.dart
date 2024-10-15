import 'dart:async';
import 'dart:io';
import 'package:jtech_base/jtech_base.dart';

// 下载进度回调
typedef DownloaderProgressCallback = void Function(
    int count, int total, int speed);

// 下载进度元组
typedef DownloadInfo = ({
  double progress,
  int speed,
  int total,
  int count,
});

/*
* 基于dio实现的文件下载器
* @author wuxubaiyang
* @Time 2023/11/26 20:50
*/
class Downloader {
  // 文件下载
  static Future<File?> start(
    String downloadUrl,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? onReceiveProgress,
    StreamController<DownloadInfo>? downloadStream,
    Duration streamDelay = const Duration(seconds: 1),
  }) async {
    int beginIndex = 0;
    final file = File(savePath);
    // 如果存在已下载文件则获取文件长度
    if (file.existsSync()) beginIndex = file.lengthSync();
    final resp = await Dio().get<ResponseBody>(
      downloadUrl,
      options: Options(
        followRedirects: false,
        responseType: ResponseType.stream,
        headers: {"range": "bytes=$beginIndex-"},
      ),
    );
    final supportPause = _supportPause(resp);
    if (!supportPause) beginIndex = 0;
    final completer = Completer<File?>();
    final raf = file.openSync(
      mode: supportPause ? FileMode.append : FileMode.write,
    );
    int lastReceived = beginIndex,
        received = beginIndex,
        total = _getContentLength(resp);
    if (supportPause) total += beginIndex;
    int tempSpeed = 0;
    final subscription = resp.data?.stream.listen((data) {
      raf.writeFromSync(data);
      received += data.length;
      tempSpeed += received - lastReceived;
      lastReceived = received;
      Debounce.c(() {
        onReceiveProgress?.call(received, total, tempSpeed);
        downloadStream?.add((
          progress: received / total,
          speed: tempSpeed,
          total: total,
          count: received,
        ));
        tempSpeed = 0;
      }, 'download_update', delay: streamDelay);
    }, onDone: () {
      raf.close();
      if (completer.isCompleted) return;
      completer.complete(file);
    }, onError: (e) {
      raf.close();
      if (completer.isCompleted) return;
      completer.complete(null);
    }, cancelOnError: true);
    // 监听取消事件
    cancelToken?.whenCancel.then((_) async {
      subscription?.cancel();
      raf.close();
      if (completer.isCompleted) return;
      completer.complete(null);
    });
    return completer.future;
  }

  // 获取文件大小
  static int _getContentLength(Response<ResponseBody> resp) {
    var contentLength = resp.headers.value(HttpHeaders.contentLengthHeader);
    return int.tryParse(contentLength ?? '') ?? 0;
  }

  // 判断是否支持断点续传
  static bool _supportPause(Response<ResponseBody> resp) {
    final keys = resp.headers.map.keys;
    return [
      HttpHeaders.contentRangeHeader,
      HttpHeaders.ifRangeHeader,
      HttpHeaders.rangeHeader,
    ].any(keys.contains);
  }
}
