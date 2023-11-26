import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/environment_package.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/loading.dart';
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
            child: IndexedStack(
              index: currentStep,
              children: [
                _buildPackageList(context),
                _buildPackageDownload(context),
                _buildPackageImport(context),
              ],
            ),
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
    return FutureBuilder<Map<String, List<EnvironmentPackage>>>(
      future: EnvironmentTool.getEnvironmentPackageList(),
      builder: (_, snap) {
        return LoadingView(
          loading: !snap.hasData,
          builder: (_) {
            final package = snap.data ?? {};
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
            onPressed: () {},
          ),
          onTap: () {},
        );
      },
    );
  }

  // 构建步骤2-下载所选环境
  Widget _buildPackageDownload(BuildContext context) {
    return SizedBox();
  }

  // 构建步骤3-导入已下载环境
  Widget _buildPackageImport(BuildContext context) {
    return SizedBox();
  }
}

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

  // 设置当前步骤
  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
}
