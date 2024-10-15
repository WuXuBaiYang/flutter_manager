import 'package:flutter/material.dart';
import 'package:flutter_manager/model/env_package.dart';

/*
* 远程环境安装包列表组件
* @author wuxubaiyang
* @Time 2023/11/27 9:53
*/
class EnvironmentRemoteList extends StatelessWidget {
  // 缓存搜索框控制器
  final _searchControllerMap = <String, TextEditingController>{};

  // 渠道安装包信息
  final Map<String, List<EnvironmentPackage>> channelPackages;

  // 启动下载回调
  final ValueChanged<EnvironmentPackage>? onStartDownload;

  // 默认展示下标
  final int initialIndex;

  // 复制链接回调
  final ValueChanged<EnvironmentPackage>? onCopyLink;

  EnvironmentRemoteList({
    super.key,
    required this.channelPackages,
    this.onCopyLink,
    this.onStartDownload,
    String initialChannel = 'stable',
  }) : initialIndex = channelPackages.keys.toList().indexOf(initialChannel);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: channelPackages.length,
      child: Column(children: [
        TabBar(
          tabs: List.generate(channelPackages.length,
              (i) => Tab(text: channelPackages.keys.elementAt(i))),
        ),
        Expanded(
          child: TabBarView(
            children: List.generate(channelPackages.length, (i) {
              final entity = channelPackages.entries.elementAt(i);
              return _buildPackageList(context, entity.key, entity.value);
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
  Widget _buildPackageList(
      BuildContext context, String channel, List<EnvironmentPackage> packages) {
    final controller = _getSearchController(channel);
    return StatefulBuilder(
      builder: (_, setState) {
        final tempList = controller.text.isNotEmpty
            ? packages.where((e) => e.search(controller.text)).toList()
            : packages;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SearchBar(
                hintText: '输入过滤条件',
                controller: controller,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tempList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final item = tempList[i];
                  return _buildPackageListItem(context, item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建包列表子项
  Widget _buildPackageListItem(BuildContext context, EnvironmentPackage item) {
    final iconData = item.hasDownload
        ? Icons.download_done_rounded
        : (item.hasTemp
            ? Icons.download_for_offline_rounded
            : Icons.download_rounded);
    final subText = 'Dart · ${item.dartVersion} · ${item.dartArch}';
    final startTooltip = {
      Icons.download_rounded: '下载',
      Icons.download_done_rounded: '已下载',
      Icons.download_for_offline_rounded: '继续下载',
    }[iconData];
    return ListTile(
      title: Text(item.title),
      subtitle: Text(subText),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          tooltip: '复制下载链接',
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => onCopyLink?.call(item),
        ),
        IconButton(
          icon: Icon(iconData),
          tooltip: startTooltip,
          onPressed: () => onStartDownload?.call(item),
        ),
      ]),
      onTap: () => onStartDownload?.call(item),
    );
  }
}
