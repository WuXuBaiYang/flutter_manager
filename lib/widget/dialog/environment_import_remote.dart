import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/environment/remote_list.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示远程导入环境弹窗
Future<Environment?> showEnvironmentImportRemote(BuildContext context,
    {Environment? environment}) {
  return showDialog<Environment>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const EnvironmentImportRemoteDialog(),
  );
}

/*
* 环境导入弹窗-远程
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentImportRemoteDialog extends ProviderView {
  const EnvironmentImportRemoteDialog({super.key});

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<EnvironmentRemoteImportDialogProvider>(
          create: (context) => EnvironmentRemoteImportDialogProvider(context),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final currentStep =
        context.watch<EnvironmentRemoteImportDialogProvider>().currentStep;
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    final savePath = provider.downloadInfo?.path;
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
          onPressed: _importPressed(context, currentStep, savePath),
          child: const Text('导入'),
        ),
      ],
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
    return Selector<EnvironmentRemoteImportDialogProvider, DownloadInfo?>(
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
    return LocalPathFormField(
      label: '安装路径',
      hint: '请选择安装路径',
      initialValue: provider.formData.path,
      onSaved: (v) => provider.updateFormData(path: v),
    );
  }

  // 构建表单项-信息
  Widget _buildFormFieldInfo(
      BuildContext context, EnvironmentPackage package) {
    return Card(
      child: ListTile(
        title: Text(package.title),
        subtitle: Text(package.fileName),
      ),
    );
  }

  // 导入方法
  VoidCallback? _importPressed(
      BuildContext context, int currentStep, String? savePath) {
    if (currentStep >= 2 || savePath == null) return null;
    final provider = context.read<EnvironmentRemoteImportDialogProvider>();
    return () async {
      final result =
          await provider.submitForm(context, savePath).loading(context);
      if (result == null || !context.mounted) return;
      Navigator.pop(context, result);
    };
  }
}

// 下载信息元组类型
typedef DownloadInfo = ({
  EnvironmentPackage? package,
  String path,
  int totalSize,
  int speed
});

// 环境远程导入弹窗表单数据元组
typedef EnvironmentImportRemoteDialogForm = ({
  String path,
});

/*
* 远程环境导入弹窗状态管理
* @author wuxubaiyang
* @Time 2023/11/26 16:28
*/
class EnvironmentRemoteImportDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 当前步骤
  int _currentStep = 0;

  // 当前步骤
  int get currentStep => _currentStep;

  // 下载取消key
  CancelToken? _cancelToken;

  // 下载更新定时器
  Timer? _downloadTimer;

  // 下载信息元组
  DownloadInfo? _downloadInfo;

  // 获取下载信息元组
  DownloadInfo? get downloadInfo => _downloadInfo;

  // 表单数据
  EnvironmentImportRemoteDialogForm _formData = (path: '');

  // 获取表单数据
  EnvironmentImportRemoteDialogForm get formData => _formData;

  // 下载进度流
  final downloadProgress = StreamController<double?>.broadcast();

  EnvironmentRemoteImportDialogProvider(super.context);

  // 更新表单数据
  void updateFormData({String? path}) =>
      _formData = (path: path ?? _formData.path);

  // 导入环境
  Future<Environment?> submitForm(
      BuildContext context, String archiveFile) async {
    try {
      final formState = formKey.currentState;
      if (!(formState?.validate() ?? false)) return null;
      formState!.save();
      return context.environment.importArchive(archiveFile, _formData.path);
    } catch (e) {
      Notice.showError(context, message: e.toString(), title: '操作失败');
    }
    return null;
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
  Future<void> startImport(
      EnvironmentPackage package, String filePath) async {
    _currentStep = 2;
    updateFormData(path: await EnvironmentTool.getDefaultInstallPath(package));
    _updateDownloadInfo(package: package, path: filePath);
  }

  // 更新下载信息
  void _updateDownloadInfo({
    EnvironmentPackage? package,
    String? path,
    int? totalSize,
    int? speed,
  }) {
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
