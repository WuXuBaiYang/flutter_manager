import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
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
      create: (_) => EnvironmentImportDialogProvider(context, environment),
      builder: (context, _) {
        return CustomDialog(
          scrollable: true,
          content: _buildContent(context),
          title: Text('${isEdit ? '编辑' : '添加'}环境'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(isEdit ? '修改' : '添加'),
              onPressed: () => _submitForm(context),
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
    return LocalPathFormField(
      label: 'flutter路径',
      hint: '请选择flutter路径',
      initialValue: provider.formData.path,
      validator: (v) {
        if (!EnvironmentTool.isPathAvailable(v!)) {
          return '路径不可用';
        }
        return null;
      },
    );
  }

  // 提交表单
  void _submitForm(BuildContext context) {
    context
        .read<EnvironmentImportDialogProvider>()
        .submitForm(context, environment)
        .loading(context)
        .then((result) {
      if (result != null) Navigator.pop(context, result);
    }).catchError((e) {
      SnackTool.showMessage(context, message: '操作失败：${e.toString()}');
    });
  }
}

// 环境导入弹窗表单数据元组
typedef EnvironmentImportDialogFormTuple = ({
  String path,
});

/*
* 环境导入弹窗状态管理
* @author wuxubaiyang
* @Time 2023/11/26 16:11
*/
class EnvironmentImportDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 表单数据
  EnvironmentImportDialogFormTuple _formData = (path: '');

  // 获取表单数据
  EnvironmentImportDialogFormTuple get formData => _formData;

  EnvironmentImportDialogProvider(super.context, Environment? item) {
    updateFormData(path: item?.path);
  }

  // 更新表单数据
  void updateFormData({String? path}) =>
      _formData = (path: path ?? _formData.path);

  // 导入环境
  Future<Environment?> submitForm(
      BuildContext context, Environment? environment) async {
    final formState = formKey.currentState;
    if (!(formState?.validate() ?? false)) return null;
    formState!.save();
    final provider = context.read<EnvironmentProvider>();
    return environment != null
        ? provider.refresh(environment..path = _formData.path)
        : provider.import(_formData.path);
  }
}
