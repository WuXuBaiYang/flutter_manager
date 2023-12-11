import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/project.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/form_field/color_picker.dart';
import 'package:flutter_manager/widget/form_field/project_logo.dart';
import 'package:flutter_manager/widget/form_field/project_pinned.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

/*
* 项目导入弹窗
* @author wuxubaiyang
* @Time 2023/11/27 14:19
*/
class ProjectImportDialog extends StatelessWidget {
  // 项目对象
  final Project? project;

  const ProjectImportDialog({super.key, this.project});

  // 展示弹窗
  static Future<Project?> show(BuildContext context, {Project? project}) {
    return showDialog<Project>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectImportDialog(
        project: project,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = project != null;
    return ChangeNotifierProvider(
      create: (_) => ProjectImportDialogProvider(context, project),
      builder: (context, _) {
        final provider = context.watch<ProjectImportDialogProvider>();
        return CustomDialog(
          scrollable: true,
          title: Text('${isEdit ? '编辑' : '添加'}项目'),
          content: _buildContent(context),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(isEdit ? '修改' : '添加'),
              onPressed: () =>
                  provider.submitForm().loading(context).then((result) {
                if (result != null) Navigator.pop(context, result);
              }),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            _buildFormFieldLogo(context),
            const SizedBox(width: 14),
            Expanded(child: _buildFormFieldLabel(context)),
          ]),
          _buildFormFieldPath(context),
          _buildFormFieldEnvironment(context),
          _buildFormFieldColor(context),
          _buildFormFieldPinned(context),
        ].expand((e) => [e, const SizedBox(height: 8)]).toList()
          ..removeLast(),
      ),
    );
  }

  // 构建表单项-项目图标
  Widget _buildFormFieldLogo(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return ProjectLogoFormField(
      fieldKey: provider.logoFormFieldKey,
      initialValue: provider.formData.logo,
      onSaved: (v) => provider.updateFormData(logo: v),
    );
  }

  // 构建表单项-项目别名
  Widget _buildFormFieldLabel(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return TextFormField(
      key: provider.labelFormFieldKey,
      initialValue: provider.formData.label,
      onSaved: (v) => provider.updateFormData(label: v),
      decoration: const InputDecoration(
        labelText: '别名',
        hintText: '请输入别名',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入项目别名';
        }
        return null;
      },
    );
  }

  // 构建表单项-项目路径
  Widget _buildFormFieldPath(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return LocalPathFormField(
      label: '项目路径',
      hint: '请选择项目路径',
      onPathSelected: provider.pathUpdate,
      initialValue: provider.formData.path,
      validator: (v) {
        if (!ProjectTool.isPathAvailable(v!)) {
          return '路径不可用';
        }
        return null;
      },
    );
  }

  // 构建表单项-环境
  Widget _buildFormFieldEnvironment(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    final environments = context.read<EnvironmentProvider>().environments;
    final envId = provider.formData.envId;
    return DropdownButtonFormField<Id>(
      key: provider.envFormFieldKey,
      value: envId >= 0 ? envId : null,
      hint: const Text('请选择环境'),
      onChanged: (v) {},
      validator: (v) {
        if (v == null) {
          return '请选择环境';
        }
        return null;
      },
      onSaved: (v) {
        provider.updateFormData(envId: v);
      },
      items: environments
          .map((e) => DropdownMenuItem(
                value: e.id,
                child: Text(e.title),
              ))
          .toList(),
    );
  }

  // 构建表单项-颜色
  Widget _buildFormFieldColor(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return ColorPickerFormField(
      initialValue: Color(provider.formData.color),
      onSaved: (v) => provider.updateFormData(color: v?.value),
    );
  }

  // 构建表单项-置顶
  Widget _buildFormFieldPinned(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return ProjectPinnedFormField(
      initialValue: provider.formData.pinned,
      onSaved: (v) => provider.updateFormData(pinned: v),
    );
  }
}

// 项目导入弹窗表单数据元组
typedef ProjectImportDialogFormTuple = ({
  String path,
  String label,
  String logo,
  Id envId,
  int color,
  bool pinned,
});

/*
* 项目导入弹窗状态管理类
* @author wuxubaiyang
* @Time 2023/11/27 14:25
*/
class ProjectImportDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 别名表单项key
  final labelFormFieldKey = GlobalKey<FormFieldState<String>>(),
      logoFormFieldKey = GlobalKey<FormFieldState<String>>(),
      envFormFieldKey = GlobalKey<FormFieldState<Id>>();

  // 表单数据
  ProjectImportDialogFormTuple _formData = (
    path: '',
    label: '',
    logo: '',
    envId: -1,
    color: Colors.transparent.value,
    pinned: false,
  );

  // 获取表单数据
  ProjectImportDialogFormTuple get formData => _formData;

  ProjectImportDialogProvider(super.context, Project? item) {
    initialize(item);
  }

  // 初始化数据
  Future<void> initialize(Project? item) async {
    if (item != null && item.envId >= 0) {
      return updateFormData(
        path: item.path,
        label: item.label,
        logo: item.logo,
        envId: item.envId,
        color: item.color,
        pinned: item.pinned,
      );
    }
    final envs = await database.getEnvironmentList(orderDesc: true);
    if (envs.isNotEmpty) envFormFieldKey.currentState?.didChange(envs.first.id);
  }

  // 导入项目
  Future<Project?> submitForm() async {
    try {
      final formState = formKey.currentState;
      if (!(formState?.validate() ?? false)) return null;
      formState!.save();
      if (_formData.envId < 0) throw Exception('缺少环境信息');
      return context.read<ProjectProvider>().update(
            Project()
              ..path = _formData.path
              ..label = _formData.label
              ..logo = _formData.logo
              ..envId = _formData.envId
              ..color = _formData.color
              ..pinned = _formData.pinned,
          );
    } catch (e) {
      showMessage('操作失败：${e.toString()}');
    }
    return null;
  }

  // 当项目路径更新时调用
  Future<void> pathUpdate(String? path) async {
    if (path?.isEmpty ?? true) return;
    final project = await ProjectTool.getProjectInfo(path!);
    if (project == null) return;
    labelFormFieldKey.currentState?.didChange(project.label);
    logoFormFieldKey.currentState?.didChange(project.logo);
  }

  // 更新表单数据
  void updateFormData({
    String? path,
    String? label,
    String? logo,
    Id? envId,
    int? color,
    bool? pinned,
  }) =>
      _formData = (
        path: path ?? _formData.path,
        label: label ?? _formData.label,
        logo: logo ?? _formData.logo,
        envId: envId ?? _formData.envId,
        color: color ?? _formData.color,
        pinned: pinned ?? _formData.pinned,
      );
}
