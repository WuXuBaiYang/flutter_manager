import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:jtech_base/jtech_base.dart';

// 导入本地环境弹窗
Future<Environment?> showImportEnvLocal(
  BuildContext context, {
  Environment? env,
}) {
  return showDialog<Environment>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ImportEnvLocalDialog(env: env),
  );
}

/*
* 本地环境导入弹窗
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class ImportEnvLocalDialog extends ProviderView<ImportEnvLocalDialogProvider> {
  // 环境对象
  final Environment? env;

  ImportEnvLocalDialog({super.key, this.env});

  @override
  ImportEnvLocalDialogProvider createProvider(BuildContext context) =>
      ImportEnvLocalDialogProvider(context, env ?? Environment());

  // 判断是否为编辑状态
  bool get _isEdite => env != null;

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      content: _buildContent(context),
      title: Text('${_isEdite ? '编辑' : '添加'}环境'),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: Text(_isEdite ? '修改' : '添加'),
          onPressed: () => provider.submit(_isEdite).loading(context),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Selector<ImportEnvLocalDialogProvider, Environment>(
      selector: (_, provider) => provider.env,
      builder: (_, env, __) {
        return Form(
          key: provider.formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildFormFieldPath(context, env),
          ]),
        );
      },
    );
  }

  // 构建表单项-flutter路径
  Widget _buildFormFieldPath(BuildContext context, Environment env) {
    return LocalPathFormField(
      label: 'flutter路径',
      initialValue: env.path,
      hint: '请选择flutter路径',
      onSaved: (v) => provider.updateFormData(path: v),
      validator: (v) {
        if (!EnvironmentTool.isAvailable(v)) {
          return '路径不可用';
        }
        return null;
      },
    );
  }
}

class ImportEnvLocalDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  ImportEnvLocalDialogProvider(super.context, this._env);

  // 环境数据对象
  Environment _env;

  // 获取环境
  Environment get env => _env;

  // 导入环境
  Future<Environment?> submit(bool isEdite) async {
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      final result = await (isEdite
          ? context.env.refresh(_env)
          : context.env.import(_env.path));
      if (context.mounted) context.pop();
      return result;
    } catch (e) {
      showNoticeError(e.toString(), title: '环境导入失败');
    }
    return null;
  }

  // 更新表单数据
  void updateFormData({String? path}) {
    _env = _env.copyWith(path: path);
    notifyListeners();
  }
}
