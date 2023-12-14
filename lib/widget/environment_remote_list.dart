import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/tool/notice.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/loading.dart';
import 'package:provider/provider.dart';

// 开始下载回调
typedef StartDownloadCallback = void Function(
    EnvironmentPackageTuple package, String savePath);

/*
* 远程环境安装包列表组件
* @author wuxubaiyang
* @Time 2023/11/27 9:53
*/
class EnvironmentRemoteList extends StatelessWidget {
  // 开始下载回调
  final StartDownloadCallback? startDownload;

  EnvironmentRemoteList({super.key, this.startDownload});

  // 缓存搜索框控制器
  final _searchControllerMap = <String, TextEditingController>{};

  // providers
  final _providers = [
    FutureProvider<EnvironmentPackageResult>(
      initialData: const {},
      create: (_) => EnvironmentTool.getEnvironmentPackageList(),
    ),
    FutureProvider<DownloadedFileTuple>(
      initialData: (downloaded: <String>[], tmp: <String>[]),
      create: (_) => EnvironmentTool.getDownloadedFileList(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      builder: (context, _) {
        final package = context.watch<EnvironmentPackageResult>();
        return LoadingView(
          loading: package.isEmpty,
          builder: (_) {
            return _buildContent(context, package);
          },
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context, EnvironmentPackageResult package) {
    final downloadFile = context.watch<DownloadedFileTuple>();
    final stableIndex = package.keys.toList().indexOf('stable');
    return DefaultTabController(
      length: package.length,
      initialIndex: stableIndex,
      child: Column(children: [
        TabBar(
          tabs: List.generate(package.length, (i) {
            return Tab(text: package.keys.elementAt(i));
          }),
        ),
        Expanded(
          child: TabBarView(
            children: List.generate(package.length, (i) {
              final packages = package.values.elementAt(i);
              return _buildPackageChannelTabView(
                  context, package.keys.elementAt(i), packages, downloadFile);
            }),
          ),
        ),
      ]),
    );
  }

  // 根据渠道key获取搜索框控制器
  TextEditingController _getSearchController(String key) =>
      _searchControllerMap[key] ??= TextEditingController();

  // 构建安装包渠道列表
  Widget _buildPackageChannelTabView(
    BuildContext context,
    String channel,
    List<EnvironmentPackageTuple> packages,
    DownloadedFileTuple downloadFile,
  ) {
    final controller = _getSearchController(channel);
    return StatefulBuilder(
      builder: (_, setState) {
        final temp = controller.text.isNotEmpty
            ? packages.where((e) => e.search(controller.text)).toList()
            : packages;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SearchBar(
                hintText: '输入过滤条件',
                controller: controller,
                onChanged: (v) => setState(() {}),
              ),
            ),
            Expanded(
                child: _buildPackageChannelList(context, temp, downloadFile)),
          ],
        );
      },
    );
  }

  // 构建安装包渠道列表
  Widget _buildPackageChannelList(
    BuildContext context,
    List<EnvironmentPackageTuple> packages,
    DownloadedFileTuple downloadFile,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: packages.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final item = packages[i];
        final savePath = downloadFile.downloaded
            .firstWhere((e) => e.contains(item.fileName), orElse: () => '');
        final iconData = savePath.isNotEmpty
            ? Icons.download_done_rounded
            : (downloadFile.tmp.any((e) => e.contains(item.fileName))
                ? Icons.download_for_offline_rounded
                : Icons.download_rounded);
        return ListTile(
          title: Text(item.title),
          subtitle: Text('Dart · ${item.dartVersion} · ${item.dartArch}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '复制下载链接',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.url));
                  NoticeTool.success(context, message: '已复制下载链接');
                },
              ),
              IconButton(
                tooltip: {
                  Icons.download_rounded: '下载',
                  Icons.download_done_rounded: '已下载',
                  Icons.download_for_offline_rounded: '继续下载',
                }[iconData],
                icon: Icon(iconData),
                onPressed: () => startDownload?.call(item, savePath),
              ),
            ],
          ),
          onTap: () => startDownload?.call(item, savePath),
        );
      },
    );
  }
}
