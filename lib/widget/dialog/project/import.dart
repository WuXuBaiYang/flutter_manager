import 'package:flutter/material.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/form_field/color_picker.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:flutter_manager/widget/form_field/project_logo.dart';
import 'package:flutter_manager/widget/form_field/project_pinned.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示项目导入弹窗
Future<Project?> showImportProject(BuildContext context, {Project? project}) {
  return showDialog<Project>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ImportProjectDialog(
      project: project,
    ),
  );
}

/*
* 项目导入弹窗
* @author wuxubaiyang
* @Time 2023/11/27 14:19
*/
class ImportProjectDialog extends ProviderView<ImportProjectDialogProvider> {
  // 项目对象
  final Project? project;

  ImportProjectDialog({super.key, this.project});

  @override
  ImportProjectDialogProvider? createProvider(BuildContext context) =>
      ImportProjectDialogProvider(context, project ?? Project());

  // 判断是否为编辑状态
  bool get isEdit => project != null;

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      scrollable: true,
      title: Text('${isEdit ? '编辑' : '添加'}项目'),
      content: _buildContent(context),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: Text(isEdit ? '修改' : '添加'),
          onPressed: () => provider.submit().loading(context),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Form(
      key: provider.formKey,
      child: createSelector<Project>(
        selector: (_, provider) => provider.project,
        builder: (_, project, __) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              _buildFieldLogo(context, project),
              const SizedBox(width: 14),
              Expanded(child: _buildFieldLabel(context, project)),
            ]),
            const SizedBox(height: 8),
            _buildFieldPath(context, project),
            const SizedBox(height: 8),
            _buildFieldEnv(context, project),
            const SizedBox(height: 8),
            _buildFieldColor(context, project),
            const SizedBox(height: 8),
            _buildFieldPinned(context, project),
          ]);
        },
      ),
    );
  }

  // 构建表单项-项目图标
  Widget _buildFieldLogo(BuildContext context, Project project) {
    return ProjectLogoFormField(
      initialValue: project.logo,
      fieldKey: provider.logoFormFieldKey,
      onSaved: (v) => provider.updateFormData(logo: v),
    );
  }

  // 构建表单项-项目别名
  Widget _buildFieldLabel(BuildContext context, Project project) {
    final decoration = InputDecoration(
      labelText: '别名',
      hintText: '请输入别名',
    );
    return TextFormField(
      decoration: decoration,
      initialValue: project.label,
      key: provider.labelFormFieldKey,
      onSaved: (v) => provider.updateFormData(label: v),
      validator: (value) {
        if (value?.isNotEmpty != true) return '请输入项目别名';
        return null;
      },
    );
  }

  // 构建表单项-项目路径
  Widget _buildFieldPath(BuildContext context, Project project) {
    return LocalPathFormField(
      label: '项目路径',
      hint: '请选择项目路径',
      initialValue: project.path,
      onPathSelected: provider.pathUpdate,
      onSaved: (v) => provider.updateFormData(path: v),
      validator: (v) {
        if (!ProjectTool.isPathAvailable(v!)) return '路径不可用';
        return null;
      },
    );
  }

  // 构建表单项-环境
  Widget _buildFieldEnv(BuildContext context, Project project) {
    return Selector<EnvironmentProvider, List<Environment>>(
      selector: (_, provider) => provider.environments,
      builder: (_, environments, __) {
        return DropdownButtonFormField<Environment>(
          onChanged: (v) {},
          hint: const Text('请选择环境'),
          value: project.environment ?? environments.firstOrNull,
          onSaved: (v) => provider.updateFormData(environment: v),
          validator: (v) {
            if (v == null) return '请选择环境';
            return null;
          },
          items: environments
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.title),
                  ))
              .toList(),
        );
      },
    );
  }

  // 构建表单项-颜色
  Widget _buildFieldColor(BuildContext context, Project project) {
    return ColorPickerFormField(
      initialValue: project.color,
      onSaved: (v) => provider.updateFormData(color: v),
    );
  }

  // 构建表单项-置顶
  Widget _buildFieldPinned(BuildContext context, Project project) {
    return ProjectPinnedFormField(
      initialValue: project.pinned,
      onSaved: (v) => provider.updateFormData(pinned: v),
    );
  }
}

class ImportProjectDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 别名表单项key
  final labelFormFieldKey = GlobalKey<FormFieldState<String>>(),
      logoFormFieldKey = GlobalKey<FormFieldState<String>>();

  ImportProjectDialogProvider(super.context, this._project);

  // 项目信息
  Project _project;

  // 获取项目信息
  Project get project => _project;

  // 导入项目
  Future<Project?> submit() async {
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      if (project.environment == null) throw Exception('缺少环境信息');
      final result = await context.project.update(project);
      if (result != null && context.mounted) context.pop();
      return result;
    } catch (e) {
      showNoticeError(e.toString(), title: '项目导入失败');
    }
    return null;
  }

  // 当项目路径更新时调用
  Future<void> pathUpdate(String? path) async {
    if (path?.isEmpty ?? true) return;
    final result = await ProjectTool.getProjectInfo(path!);
    if (result == null) return;
    labelFormFieldKey.currentState?.didChange(result.label);
    logoFormFieldKey.currentState?.didChange(result.logo);
    _project = result;
    notifyListeners();
  }

  // 更新表单数据
  void updateFormData({
    String? path,
    String? label,
    String? logo,
    Environment? environment,
    Color? color,
    bool? pinned,
  }) {
    _project = _project.copyWith(
      path: path ?? _project.path,
      label: label ?? _project.label,
      logo: logo ?? _project.logo,
      environment: environment ?? _project.environment,
      color: color ?? _project.color,
      pinned: pinned ?? _project.pinned,
    );
    notifyListeners();
  }
}
