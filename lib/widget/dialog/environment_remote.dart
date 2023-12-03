import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/environment_package.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/dialog/environment_remote_list.dart';
import 'package:flutter_manager/widget/local_path.dart';
import 'package:provider/provider.dart';

/*
* 环境导入弹窗-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentRemoteImportDialog extends StatelessWidget {
  const EnvironmentRemoteImportDialog({super.key});

  // 展示弹窗
  static Future<Environment?> show(BuildContext context,
      {Environment? environment}) {
    return showDialog<Environment>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EnvironmentRemoteImportDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnvironmentRemoteImportDialogProvider(),
      builder: (context, _) {
        final currentStep =
            context.watch<EnvironmentRemoteImportDialogProvider>().currentStep;
        final provider = context.read<EnvironmentRemoteImportDialogProvider>();
        final savePath = provider.downloadInfo?.path;
        return AlertDialog(
          title: Text(['选择', '下载', '导入'][currentStep]),
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
              onPressed: (currentStep >= 2 && savePath != null)
                  ? () => provider.import(context, savePath)
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
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    return EnvironmentRemoteList(
      startDownload: (package, savePath) {
        savePath.isNotEmpty
            ? provider.startImport(package, savePath)
            : provider.startDownload(package);
      },
    );
  }

  // 构建步骤2-下载所选环境
  Widget _buildPackageDownload(BuildContext context) {
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    return Selector<EnvironmentRemoteImportDialogProvider, DownloadInfoTuple?>(
      selector: (_, provider) => provider.downloadInfo,
      builder: (_, downloadInfo, __) {
        final speed = FileTool.formatSize(downloadInfo?.speed ?? 0);
        final totalSize = FileTool.formatSize(downloadInfo?.totalSize ?? 0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(downloadInfo?.package?.fileName ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            StreamProvider<double?>.value(
              initialData: null,
              value: provider.downloadProgress.stream,
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
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    final package = provider.downloadInfo?.package;
    if (package == null) return const Text('缺少必须参数');
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormFieldPath(context),
          _buildFormFieldInfo(context, package),
        ].expand((e) => [e, const SizedBox(height: 8)]).toList()
          ..removeLast(),
      ),
    );
  }

  // 构建表单项-路径
  Widget _buildFormFieldPath(BuildContext context) {
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    return LocalPathTextFormField(
      label: '安装路径',
      hint: '请选择安装路径',
      controller: provider.localPathController,
    );
  }

  // 构建表单项-信息
  Widget _buildFormFieldInfo(BuildContext context, EnvironmentPackage package) {
    return Card(
      child: ListTile(
        title: Text(package.title),
        subtitle: Text(package.fileName),
      ),
    );
  }
}

// 下载信息元组类型
typedef DownloadInfoTuple = ({
  EnvironmentPackage? package,
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
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 输入框控制器
  final localPathController = TextEditingController();

  // 当前步骤
  int _currentStep = 0;

  // 当前步骤
  int get currentStep => _currentStep;

  // 下载取消key
  CancelToken? _cancelToken;

  // 下载更新定时器
  Timer? _downloadTimer;

  // 下载信息元组
  DownloadInfoTuple? _downloadInfo;

  // 获取下载信息元组
  DownloadInfoTuple? get downloadInfo => _downloadInfo;

  // 下载进度流
  final downloadProgress = StreamController<double?>.broadcast();

  // 导入环境
  Future<void> import(BuildContext context, String archiveFile) async {
    if (!formKey.currentState!.validate()) return;
    final path = localPathController.text;
    final provider = context.read<EnvironmentProvider>();
    final future = provider.importArchive(archiveFile, path);
    Loading.show<Environment?>(context, loadFuture: future)?.then((result) {
      Navigator.pop(context, result);
    }).catchError((e) {
      final message = '导入失败：$e';
      SnackTool.showMessage(context, message: message);
    });
  }

  // 启动下载
  Future<void> startDownload(EnvironmentPackage package) async {
    _currentStep = 1;
    _cancelToken = CancelToken();
    int tempSpeed = 0, totalSize = 0;
    _downloadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDownloadInfo(totalSize: totalSize, speed: tempSpeed);
      tempSpeed = 0;
    });
    _updateDownloadInfo(package: package);
    final result = await EnvironmentTool.downloadPackage(
      package.url,
      cancelToken: _cancelToken,
      onReceiveProgress: (count, total, speed) {
        totalSize = total;
        tempSpeed += speed;
        downloadProgress.add(count / total);
      },
    );
    if (result == null) throw Exception('下载失败');
    return startImport(package, result);
  }

  // 开始导入
  Future<void> startImport(EnvironmentPackage package, String filePath) async {
    _currentStep = 2;
    localPathController.text =
        await EnvironmentTool.getDefaultInstallPath(package) ?? '';
    _updateDownloadInfo(
      package: package,
      path: filePath,
    );
  }

  // 更新下载信息
  void _updateDownloadInfo(
      {EnvironmentPackage? package, String? path, int? totalSize, int? speed}) {
    _downloadInfo = (
      package: package ?? _downloadInfo?.package,
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
