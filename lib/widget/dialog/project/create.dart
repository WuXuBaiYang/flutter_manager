import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/model/create_template.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:flutter_manager/widget/form_field/check_field.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示项目创建弹窗
Future<Project?> showCreateProject(BuildContext context) {
  return showDialog<Project>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CreateProjectView(),
  );
}

/*
* 项目创建弹窗
* @author wuxubaiyang
* @Time 2025/6/17 14:27
*/
class CreateProjectView extends ProviderView<CreateProjectProvider> {
  CreateProjectView({super.key});

  @override
  CreateProjectProvider createProvider(BuildContext context) =>
      CreateProjectProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: Text('创建项目'),
      content: _buildContent(),
      actions: [
        TextButton(onPressed: context.pop, child: const Text('取消')),
        TextButton(
          child: Text('创建'),
          onPressed: () => provider.submit().loading(context),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent() {
    return Form(
      key: provider.formKey,
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNameField(),
          _buildFieldEnv(),
          _buildTargetDirField(),
          _buildUrlField(),
          _buildDescriptionField(),
          _buildFinishOpen(),
        ],
      ),
    );
  }

  // 项目名/应用名/数据库名字段
  Widget _buildNameField() {
    return Row(
      spacing: 14,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            autofocus: true,
            controller: provider.projectNameController,
            onSaved: (v) => provider.updateFormData(projectName: v),
            decoration: InputDecoration(
              labelText: '项目(Az09_)',
              hintText: '请输入项目',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]+')),
            ],
            validator: (value) {
              if (value?.isNotEmpty != true) return '请输入项目';
              return null;
            },
          ),
        ),
        _buildLinkIcon(),
        Expanded(
          child: TextFormField(
            onSaved: (v) => provider.updateFormData(
              appName: v?.isNotEmpty != true
                  ? provider.projectNameController.text
                  : v,
            ),
            decoration: InputDecoration(labelText: '应用', hintText: '请输入应用'),
          ),
        ),
        _buildLinkIcon(),
        Expanded(
          child: TextFormField(
            onSaved: (v) => provider.updateFormData(
              dbName: v?.isNotEmpty != true
                  ? provider.projectNameController.text
                  : v,
            ),
            decoration: InputDecoration(labelText: '数据库', hintText: '请输入数据库'),
          ),
        ),
      ],
    );
  }

  // 构建表单项-环境
  Widget _buildFieldEnv() {
    return Selector<EnvironmentProvider, List<Environment>>(
      selector: (_, provider) => provider.environments,
      builder: (_, environments, _) {
        return DropdownButtonFormField<Environment>(
          onChanged: (v) {},
          hint: const Text('请选择环境'),
          value: environments.firstOrNull,
          onSaved: (v) => provider.updateFormData(environment: v),
          validator: (v) {
            if (v == null) return '请选择环境';
            return null;
          },
          items: environments
              .map((e) => DropdownMenuItem(value: e, child: Text(e.title)))
              .toList(),
        );
      },
    );
  }

  // 输出路径
  Widget _buildTargetDirField() {
    return LocalPathFormField(
      label: '项目路径',
      hint: '请选择项目路径',
      onSaved: (v) => provider.updateFormData(targetDir: v),
      validator: (v) {
        if (!XTool.isPath(v ?? '')) return '路径不可用';
        return null;
      },
    );
  }

  // 生产地址/开发地址
  Widget _buildUrlField() {
    return Row(
      spacing: 14,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: provider.devUrlController,
            onSaved: (v) => provider.updateFormData(devUrl: v),
            decoration: InputDecoration(
              labelText: '开发地址(ip/http)',
              hintText: '请输入开发地址',
            ),
            validator: (v) {
              if (v?.isNotEmpty != true) return '请输入开发地址';
              if (!XTool.isIP(v ?? '') && !XTool.isHttp(v ?? '')) {
                return '地址不可用';
              }
              return null;
            },
          ),
        ),
        _buildLinkIcon(),
        Expanded(
          child: TextFormField(
            onSaved: (v) => provider.updateFormData(
              prodUrl: v?.isNotEmpty != true
                  ? provider.devUrlController.text
                  : v,
            ),
            decoration: InputDecoration(labelText: '生产地址', hintText: '请输入生产地址'),
            validator: (v) {
              if (!XTool.isIP(v ?? '') && !XTool.isHttp(v ?? '')) {
                return '地址不可用';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // 项目描述
  Widget _buildDescriptionField() {
    return TextFormField(
      autofocus: true,
      controller: provider.projectNameController,
      onSaved: (v) => provider.updateFormData(description: v),
      decoration: InputDecoration(labelText: '描述', hintText: '请输入描述'),
    );
  }

  // 完成时打开目录
  Widget _buildFinishOpen() {
    return CheckFormField(
      title: '完成时打开目录',
      initialValue: false,
      onSaved: (v) => provider.updateFormData(openWhenFinish: v),
    );
  }

  // 构建链接标志
  Widget _buildLinkIcon() {
    return Tooltip(message: '右侧为空时与最左侧保持一致', child: Icon(Icons.link, size: 16));
  }
}

class CreateProjectProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 项目名称/开发地址控制器
  final projectNameController = TextEditingController(),
      devUrlController = TextEditingController();

  // 表单项项目名/数据库名key
  final appNameFormFieldKey = GlobalKey<FormFieldState<String>>(),
      dbNameFormFieldKey = GlobalKey<FormFieldState<String>>();

  CreateProjectProvider(super.context);

  // 创建项目模板
  CreateTemplate _template = CreateTemplate.empty();

  // 创建项目
  Future<void> submit() async {}

  // 更新表单数据
  void updateFormData({
    String? devUrl,
    String? targetDir,
    String? projectName,
    String? appName,
    String? dbName,
    String? prodUrl,
    String? description,
    bool? openWhenFinish,
    Environment? environment,
  }) {
    _template = _template.copyWith(
      prodUrl: prodUrl ?? _template.prodUrl,
      description: description ?? _template.description,
      openWhenFinish: openWhenFinish ?? _template.openWhenFinish,
      appName: appName ?? _template.appName,
      dbName: dbName ?? _template.dbName,
      devUrl: devUrl ?? _template.devUrl,
      targetDir: targetDir ?? _template.targetDir,
      projectName: projectName ?? _template.projectName,
      flutterBin: environment?.binPath ?? _template.flutterBin,
    );
  }
}
