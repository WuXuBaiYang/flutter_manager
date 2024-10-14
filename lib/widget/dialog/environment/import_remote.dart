import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/model/env_package.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/dialog/environment/remote_list.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示远程导入环境弹窗
Future<Environment?> showImportEnvRemote(BuildContext context) {
  return showDialog<Environment>(
    context: context,
    builder: (_) => ImportEnvRemoteDialog(),
  );
}

/*
* 环境导入弹窗-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class ImportEnvRemoteDialog extends ProviderView {
  ImportEnvRemoteDialog({super.key});

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<ImportEnvRemoteDialogProvider>(
          create: (context) => ImportEnvRemoteDialogProvider(context),
        ),
      ];

  // 获取当前代理
  ImportEnvRemoteDialogProvider get _envProvider =>
      context.read<ImportEnvRemoteDialogProvider>();

  @override
  Widget buildWidget(BuildContext context) {
    return Selector<ImportEnvRemoteDialogProvider, int>(
      selector: (_, provider) => provider.currentStep,
      builder: (_, currentStep, __) {
        return CustomDialog(
          title: Text(['选择', '下载', '导入'][currentStep]),
          constraints: const BoxConstraints.tightFor(width: 340),
          content: [
            _buildPackageList(context),
            _buildPackageDownload(context),
            _buildPackageImport(context),
          ][currentStep],
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: currentStep >= 2
                  ? () => _envProvider.submit().loading(context)
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
    return LoadingFutureBuilder<
        ({
          Map<String, List<EnvironmentPackage>> channelPackages,
          DownloadEnvResult downloadResult
        })>(
      onFuture: () async => (
        channelPackages: await EnvironmentTool.getChannelPackages(),
        downloadResult: await EnvironmentTool.getDownloadResult(),
      ),
      builder: (_, result, __) {
        return EnvironmentRemoteList(
          downloadResult: result?.downloadResult,
          channelPackages: result?.channelPackages ?? {},
          onStartDownload: (result) => result.savePath != null
              ? _envProvider.startImport(result.package, result.savePath)
              : _envProvider.startDownload(result.package),
          onCopyLink: _envProvider.copyLink,
        );
      },
    );
  }

  // 构建步骤2-下载所选环境
  Widget _buildPackageDownload(BuildContext context) {
    return StreamBuilder<DownloadInfo>(
      stream: _envProvider.downloadProgress.stream,
      builder: (_, snap) {
        final downloadInfo = snap.data;
        final package = _envProvider.currentPackage;
        final speed = FileTool.formatSize(downloadInfo?.speed ?? 0);
        final totalSize = FileTool.formatSize(downloadInfo?.total ?? 0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(package?.fileName ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: context.watch<double?>(),
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
    return Selector<ImportEnvRemoteDialogProvider,
        ({EnvironmentPackage? package, String? savePath})>(
      selector: (_, provider) => (
        package: provider.currentPackage,
        savePath: provider.savePath,
      ),
      builder: (_, result, __) {
        return Form(
          key: _envProvider.formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildFormFieldPath(context, result.savePath),
            const SizedBox(height: 8),
            _buildFormFieldInfo(context, result.package),
          ]),
        );
      },
    );
  }

  // 构建表单项-路径
  Widget _buildFormFieldPath(BuildContext context, String? savePath) {
    return LocalPathFormField(
      label: '安装路径',
      hint: '请选择安装路径',
      initialValue: savePath,
      onSaved: (v) => _envProvider.updateFormData(path: v),
    );
  }

  // 构建表单项-信息
  Widget _buildFormFieldInfo(
      BuildContext context, EnvironmentPackage? package) {
    return Card(
      child: ListTile(
        title: Text(package?.title ?? ''),
        subtitle: Text(package?.fileName ?? ''),
      ),
    );
  }
}

// 下载进度元组
typedef DownloadInfo = ({
  double progress,
  int speed,
  int total,
  int count,
});

class ImportEnvRemoteDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  ImportEnvRemoteDialogProvider(super.context);

  // 当前步骤
  int _currentStep = 0;

  // 当前步骤
  int get currentStep => _currentStep;

  // 压缩包文件
  String? _archiveFile, _savePath;

  // 获取保存路径
  String? get savePath => _savePath;

  // 当前选择包信息
  EnvironmentPackage? _currentPackage;

  // 当前选择包信息
  EnvironmentPackage? get currentPackage => _currentPackage;

  // 下载进度流
  final downloadProgress = StreamController<DownloadInfo>.broadcast();

  // 下载取消key
  CancelToken? _cancelToken;

  // 启动下载
  Future<void> startDownload(EnvironmentPackage package) async {
    _currentPackage = package;
    _updateStep(1);
    int tempSpeed = 0;
    _archiveFile = await EnvironmentTool.download(
      package.url,
      cancelToken: _cancelToken = CancelToken(),
      onReceiveProgress: (count, total, speed) {
        tempSpeed += speed;
        Debounce.c(
          () {
            downloadProgress.add((
              progress: count / total,
              speed: tempSpeed,
              total: total,
              count: count,
            ));
            tempSpeed = 0;
          },
          'update_download',
          delay: Duration(seconds: 1),
        );
      },
    );
    if (_archiveFile == null) throw Exception('下载失败');
    return startImport(package);
  }

  // 开始导入
  Future<void> startImport(EnvironmentPackage package,
      [String? savePath]) async {
    _savePath = savePath ?? await EnvironmentTool.getInstallPath(package);
    _currentPackage = package;
    _updateStep(2);
  }

  // 导入环境
  Future<Environment?> submit() async {
    if (_archiveFile == null || _savePath == null) return null;
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      final result = await context.env.importArchive(_archiveFile!, _savePath!);
      if (context.mounted) context.pop();
      return result;
    } catch (e) {
      showNoticeError(e.toString(), title: '环境导入失败');
    }
    return null;
  }

  void copyLink(EnvironmentPackage package) {
    Clipboard.setData(ClipboardData(text: package.url));
    showNoticeSuccess('已复制下载链接');
  }

  // 更新表单数据
  void updateFormData({EnvironmentPackage? package, String? path}) {
    _savePath = path ?? _savePath;
    _currentPackage = package ?? _currentPackage;
    notifyListeners();
  }

  // 更新状态下标
  void _updateStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    downloadProgress.close();
    super.dispose();
  }
}
