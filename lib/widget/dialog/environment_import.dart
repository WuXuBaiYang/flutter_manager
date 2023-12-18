import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 展示导入环境弹窗
Future<Environment?> showEnvironmentImport(BuildContext context,
    {Environment? environment}) {
  return showDialog<Environment>(
    context: context,
    barrierDismissible: false,
    builder: (_) => EnvironmentImportDialog(
      environment: environment,
    ),
  );
}

/*
* 环境导入弹窗
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentImportDialog extends ProviderView {
  // 环境对象
  final Environment? environment;

  const EnvironmentImportDialog({super.key, this.environment});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider<EnvironmentImportDialogProvider>(
          create: (_) => EnvironmentImportDialogProvider(context, environment),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final isEdit = environment != null;
    final provider = context.watch<EnvironmentImportDialogProvider>();
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
          onPressed: () => provider
              .submitForm(context, environment)
              .loading(context)
              .then((result) {
            if (result != null) Navigator.pop(context, result);
          }),
        ),
      ],
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
      onSaved: (v) => provider.updateFormData(path: v),
      validator: (v) {
        if (!EnvironmentTool.isPathAvailable(v!)) {
          return '路径不可用';
        }
        return null;
      },
    );
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
    try {
      final formState = formKey.currentState;
      if (!(formState?.validate() ?? false)) return null;
      formState!.save();
      final provider = context.read<EnvironmentProvider>();
      return environment != null
          ? provider.refresh(environment..path = _formData.path)
          : provider.import(_formData.path);
    } catch (e) {
      showError(e.toString(), title: '操作失败');
    }
    return null;
  }
}
