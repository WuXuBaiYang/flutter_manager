import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/local_path.dart';
import 'package:provider/provider.dart';

/*
* 环境导入弹窗
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentImportDialog extends StatelessWidget {
  // 环境对象
  final Environment? environment;

  const EnvironmentImportDialog({super.key, this.environment});

  // 展示弹窗
  static Future<Environment?> show(BuildContext context,
      {Environment? environment}) {
    return showDialog<Environment>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EnvironmentImportDialog(
        environment: environment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = environment != null;
    return ChangeNotifierProvider<EnvironmentImportDialogProvider>(
      create: (_) => EnvironmentImportDialogProvider(environment),
      builder: (context, _) {
        return CustomDialog(
          scrollable: true,
          title: Text('${isEdit ? '编辑' : '导入'}环境'),
          content: _buildContent(context),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => context
                  .read<EnvironmentImportDialogProvider>()
                  .import(context, environment),
              child: Text(isEdit ? '修改' : '导入'),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<EnvironmentImportDialogProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormFieldPath(context),
        ].expand((e) => [e, const SizedBox(height: 8)]).toList()
          ..removeLast(),
      ),
    );
  }

  // 构建表单项-flutter路径
  Widget _buildFormFieldPath(BuildContext context) {
    final provider = context.read<EnvironmentImportDialogProvider>();
    return LocalPathTextFormField(
      label: 'flutter路径',
      hint: '请选择flutter路径',
      validator: (v) {
        if (!EnvironmentTool.isPathAvailable(v!)) {
          return '路径不可用';
        }
        return null;
      },
      controller: provider.localPathController,
    );
  }
}

/*
* 环境导入弹窗状态管理
* @author wuxubaiyang
* @Time 2023/11/26 16:11
*/
class EnvironmentImportDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 本地路径选择输入框控制器
  late final TextEditingController localPathController;

  EnvironmentImportDialogProvider(Environment? item)
      : localPathController = TextEditingController(text: item?.path ?? '');

  // 导入环境
  Future<void> import(BuildContext context, Environment? environment) async {
    if (!formKey.currentState!.validate()) return;
    final isEdit = environment != null;
    final path = localPathController.text;
    final provider = context.read<EnvironmentProvider>();
    final future = isEdit
        ? provider.refresh(environment..path = path)
        : provider.import(path);
    Loading.show<Environment?>(context, loadFuture: future)?.then((result) {
      Navigator.pop(context, result);
    }).catchError((e) {
      final message = '${isEdit ? '修改' : '导入'}失败：$e';
      SnackTool.showMessage(context, message: message);
    });
  }
}
