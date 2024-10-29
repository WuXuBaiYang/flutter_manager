import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/model/env_package.dart';
import 'package:flutter_manager/tool/download.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/dialog/environment/remote_list.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示远程导入环境弹窗
Future<Environment?> showImportEnvRemote(BuildContext context) {
  return showDialog<Environment>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ImportEnvRemoteDialog(),
  );
}

/*
* 环境导入弹窗-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class ImportEnvRemoteDialog
    extends ProviderView<ImportEnvRemoteDialogProvider> {
  ImportEnvRemoteDialog({super.key});

  @override
  ImportEnvRemoteDialogProvider createProvider(BuildContext context) =>
      ImportEnvRemoteDialogProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return createSelector<int>(
      selector: (_, provider) => provider.currentStep,
      builder: (_, currentStep, __) {
        return CustomDialog(
          title: Text(['选择', '下载', '导入'][currentStep]),
          style: CustomDialogStyle(
            constraints: const BoxConstraints.tightFor(width: 340),
          ),
          content: [
            _buildPackageList(context),
            _buildPackageDownload(context),
            _buildPackageImport(context),
          ][currentStep],
          actions: [
            TextButton(
              onPressed: context.pop,
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: currentStep >= 2
                  ? () => provider.submit().loading(context, dismissible: false)
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
    return LoadingFutureBuilder<Map<String, List<EnvironmentPackage>>>(
      future: EnvironmentTool.getChannelPackages(),
      builder: (_, channelPackages, __) {
        return EnvironmentRemoteList(
          onCopyLink: provider.copyLink,
          onStartDownload: provider.startNextStep,
          channelPackages: channelPackages,
        );
      },
    );
  }

  // 构建步骤2-下载所选环境
  Widget _buildPackageDownload(BuildContext context) {
    return StreamBuilder<DownloadInfo>(
      stream: provider.downloadProgress.stream,
      builder: (_, snap) {
        final downloadInfo = snap.data;
        final package = provider.currentPackage;
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
              value: downloadInfo?.progress,
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
    return createSelector<EnvironmentPackage?>(
      selector: (_, provider) => provider.currentPackage,
      builder: (_, currentPackage, __) {
        return Form(
          key: provider.formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildFormFieldPath(context, currentPackage?.buildPath),
            const SizedBox(height: 8),
            _buildFormFieldInfo(context, currentPackage),
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
      onSaved: (v) => provider.updateFormData(buildPath: v),
    );
  }

  // 构建表单项-信息
  Widget _buildFormFieldInfo(BuildContext context,
      EnvironmentPackage? package) {
    return Card(
      child: ListTile(
        title: Text(package?.title ?? ''),
        subtitle: Text(package?.fileName ?? ''),
      ),
    );
  }
}

class ImportEnvRemoteDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  ImportEnvRemoteDialogProvider(super.context);

  // 当前步骤
  int _currentStep = 0;

  // 当前步骤
  int get currentStep => _currentStep;

  // 当前选择包信息
  EnvironmentPackage? _currentPackage;

  // 当前选择包信息
  EnvironmentPackage? get currentPackage => _currentPackage;

  // 下载进度流
  final downloadProgress = StreamController<DownloadInfo>.broadcast();

  // 下载取消key
  CancelToken? _cancelToken;

  // 执行下一步
  Future<void> startNextStep(EnvironmentPackage package) async {
    try {
      // 已有下载路径则跳转到导入页面
      if (package.hasDownload) {
        _currentPackage = package.copyWith(
          buildPath: await EnvironmentTool.getInstallPath(package),
        );
        return _updateStep(2);
      }
      _currentPackage = package;
      // 没有则跳转并开始下载
      _updateStep(1);
      final downloadFile = await EnvironmentTool.download(
        package.url,
        downloadProgress: downloadProgress,
        cancelToken: _cancelToken = CancelToken(),
      );
      if (downloadFile == null) throw Exception('下载失败');
      // 下载完成后更新保存路径并跳转到导入页面
      return startNextStep(package.copyWith(
        downloadPath: downloadFile,
      ));
    } catch (e) {
      showNoticeError(e.toString(), title: '环境导入失败');
      if (context.mounted) context.pop();
    }
  }

  // 导入环境
  Future<Environment?> submit() async {
    if (_currentPackage?.canImport != true) return null;
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      final result = await context.env.importArchive(_currentPackage!);
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
  void updateFormData({String? buildPath}) {
    _currentPackage = _currentPackage?.copyWith(
      buildPath: buildPath,
    );
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
