import 'package:flutter/material.dart';
import 'package:flutter_manager/model/environment_package.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/loading.dart';
import 'package:provider/provider.dart';

// 开始下载回调
typedef StartDownloadCallback = void Function(
    EnvironmentPackage package, String savePath);

/*
* 远程环境安装包列表组件
* @author wuxubaiyang
* @Time 2023/11/27 9:53
*/
class EnvironmentRemoteList extends StatelessWidget {
  // 开始下载回调
  final StartDownloadCallback? startDownload;

  const EnvironmentRemoteList({super.key, this.startDownload});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<EnvironmentPackageResult>(
          initialData: const {},
          create: (_) => EnvironmentTool.getEnvironmentPackageList(),
        ),
        FutureProvider<DownloadedFileTuple>(
          initialData: (downloaded: <String>[], tmp: <String>[]),
          create: (_) => EnvironmentTool.getDownloadedFileList(),
        )
      ],
      builder: (context, _) {
        final package = context.watch<EnvironmentPackageResult>();
        final downloadFile = context.watch<DownloadedFileTuple>();
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
                    tabs: List.generate(package.length,
                        (i) => Tab(text: package.keys.elementAt(i))),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: List.generate(package.length, (i) {
                        final packages = package.values.elementAt(i);
                        return _buildPackageChannelList(packages, downloadFile);
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

  // 构建安装包渠道列表
  Widget _buildPackageChannelList(
      List<EnvironmentPackage> packages, DownloadedFileTuple downloadFile) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: packages.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final item = packages[i];
        final savePath = downloadFile.downloaded
            .firstWhere((e) => e.contains(item.fileName), orElse: () => '');
        return ListTile(
          title: Text(item.title),
          subtitle: Text('Dart · ${item.dartVersion} · ${item.dartArch}'),
          trailing: IconButton(
            icon: Icon(savePath.isNotEmpty
                ? Icons.download_done_rounded
                : (downloadFile.tmp.any((e) => e.contains(item.fileName))
                    ? Icons.download_for_offline_rounded
                    : Icons.download_rounded)),
            onPressed: () => startDownload?.call(item, savePath),
          ),
          onTap: () => startDownload?.call(item, savePath),
        );
      },
    );
  }
}
