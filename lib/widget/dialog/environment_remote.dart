import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/environment_package.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/loading.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/*
* 环境导入弹窗-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentRemoteImportDialog extends StatefulWidget {
  const EnvironmentRemoteImportDialog({super.key});

  // 展示弹窗
  static Future<void> show(BuildContext context,
      {Environment? environment}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EnvironmentRemoteImportDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() => _EnvironmentRemoteImportDialogState();
}

/*
* 环境导入弹窗状态管理类-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class _EnvironmentRemoteImportDialogState
    extends State<EnvironmentRemoteImportDialog> {
  // 状态管理
  final _provider = EnvironmentRemoteImportDialogProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      builder: (context, _) {
        final currentStep =
            context.watch<EnvironmentRemoteImportDialogProvider>().currentStep;
        return AlertDialog(
          title: const Text('下载并导入'),
          content: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 340),
            child: [
              _buildPackageList(context),
              _buildPackageDownload(context),
              _buildPackageImport(context),
            ][currentStep],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: currentStep >= 2
                  ? () {
                      ///
                    }
                  : null,
              child: const Text('导入'),
            ),
          ],
        );
      },
    );
  }

  // 构建步骤1-选择要下载的环境
  Widget _buildPackageList(BuildContext context) {
    return Selector<EnvironmentRemoteImportDialogProvider,
        Map<String, List<EnvironmentPackage>>>(
      selector: (_, provider) => provider.environmentPackage,
      builder: (_, package, __) {
        return LoadingView(
          loading: package.isEmpty,
          builder: (_) {
            final stableIndex = package.keys.toList().indexOf('stable');
            return DefaultTabController(
              length: package.length,
              initialIndex: stableIndex,
              child: Column(
                children: [
                  TabBar(
                    tabs: List.generate(
                      package.length,
                      (i) => Tab(text: package.keys.elementAt(i)),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: List.generate(package.length, (i) {
                        final packages = package.values.elementAt(i);
                        return _buildPackageChannelList(packages);
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 构建步骤1-选择要下载的环境-渠道列表
  Widget _buildPackageChannelList(List<EnvironmentPackage> packages) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: packages.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final item = packages[i];
        return ListTile(
          title: Text('Flutter · ${item.version}'),
          subtitle: Text('Dart · ${item.dartVersion} · ${item.dartArch}'),
          trailing: IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _provider.startDownload(item.url),
          ),
          onTap: () => _provider.startDownload(item.url),
        );
      },
    );
  }

  // 构建步骤2-下载所选环境
  Widget _buildPackageDownload(BuildContext context) {
    return Selector<EnvironmentRemoteImportDialogProvider, DownloadInfoTuple>(
      selector: (_, provider) => provider.downloadInfo,
      builder: (_, downloadInfo, __) {
        final speed = FileTool.formatSize(downloadInfo.speed);
        final totalSize = FileTool.formatSize(downloadInfo.totalSize);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(downloadInfo.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            StreamProvider<double?>.value(
              initialData: null,
              value: _provider.downloadProgress.stream,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: context.watch<double?>(),
                );
              },
            ),
            const SizedBox(height: 4),
            Text('$totalSize · $speed/s'),
          ],
        );
      },
    );
  }

  // 构建步骤3-导入已下载环境
  Widget _buildPackageImport(BuildContext context) {
    return SizedBox();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}

// 下载信息元组类型
typedef DownloadInfoTuple = ({
  String name,
  String path,
  int totalSize,
  int speed
});

/*
* 远程环境导入弹窗状态管理
* @author wuxubaiyang
* @Time 2023/11/26 16:28
*/
class EnvironmentRemoteImportDialogProvider extends BaseProvider {
  // 当前步骤
  int _currentStep = 0;

  // 当前步骤
  int get currentStep => _currentStep;

  // 下载取消key
  CancelToken? _cancelToken;

  // 下载更新定时器
  Timer? _downloadTimer;

  // 环境安装包
  final Map<String, List<EnvironmentPackage>> environmentPackage = {};

  // 下载信息元组
  DownloadInfoTuple? _downloadInfo;

  // 获取下载信息元组
  DownloadInfoTuple get downloadInfo =>
      _downloadInfo ?? (name: '', path: '', totalSize: 0, speed: 0);

  // 下载进度流
  final downloadProgress = StreamController<double?>.broadcast();

  EnvironmentRemoteImportDialogProvider() {
    loadEnvironmentPackage();
  }

  // 加载环境包
  Future<void> loadEnvironmentPackage() async {
    environmentPackage
        .addAll(await EnvironmentTool.getEnvironmentPackageList());
    notifyListeners();
  }

  // 启动下载
  Future<void> startDownload(String url) async {
    _currentStep = 1;
    _cancelToken = CancelToken();
    final fileName = basename(url);
    int tempSpeed = 0, totalSize = 0;
    _downloadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDownloadInfo(totalSize: totalSize, speed: tempSpeed);
      tempSpeed = 0;
    });
    _updateDownloadInfo(name: fileName);
    final result = await EnvironmentTool.downloadPackage(
      url,
      cancelToken: _cancelToken,
      onReceiveProgress: (count, total, speed) {
        totalSize = total;
        tempSpeed += speed;
        downloadProgress.add(count / total);
      },
    );
    _updateDownloadInfo(path: result ?? '');
  }

  // 更新下载信息
  void _updateDownloadInfo(
      {String? name, String? path, int? totalSize, int? speed}) {
    _downloadInfo = (
      name: name ?? _downloadInfo?.name ?? '',
      path: path ?? _downloadInfo?.path ?? '',
      totalSize: totalSize ?? _downloadInfo?.totalSize ?? 0,
      speed: speed ?? _downloadInfo?.speed ?? 0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _downloadTimer?.cancel();
    super.dispose();
  }
}
