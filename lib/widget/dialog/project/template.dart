import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/model/create_template.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/template.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:flutter_manager/widget/form_field/check_field.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示模板项目创建弹窗
Future<Project?> showTemplateCreate(BuildContext context) {
  return showDialog<Project>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TemplateCreateView(),
  );
}

/*
* 模板项目创建弹窗
* @author wuxubaiyang
* @Time 2025/6/17 14:27
*/
class TemplateCreateView extends ProviderView<TemplateCreateViewProvider> {
  TemplateCreateView({super.key});

  @override
  TemplateCreateViewProvider createProvider(BuildContext context) =>
      TemplateCreateViewProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: Text('从模板创建'),
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
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: [
              _buildNameField(),
              _buildFieldEnv(),
              _buildTargetDirField(),
              _buildUrlField(),
              _buildDescriptionField(),
              _buildFinishOpen(),
              _buildAutoAddProject(),
              Divider(),
              _buildPlatformList(),
            ],
          ),
        ),
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
      controller: provider.targetDirController,
      onSaved: (v) => provider.updateFormData(targetDir: v),
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
              if (!(XTool.isIP(v ?? '') || XTool.isHttp(v ?? ''))) {
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
              if (v?.isNotEmpty != true) return null;
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

  // 完成后自动添加到项目列表
  Widget _buildAutoAddProject() {
    return CheckFormField(
      title: '完成时导入项目',
      initialValue: provider.addProject,
      onSaved: (v) => provider.updateAddProject(v ?? false),
    );
  }

  // 构建平台选择列表
  Widget _buildPlatformList() {
    return createSelector(
      selector: (_, p) => p.platforms,
      builder: (_, platforms, _) {
        final selectAll = PlatformType.values.every(platforms.containsKey);
        return Column(
          children: [
            CheckboxListTile(
              tristate: true,
              title: Text('平台'),
              contentPadding: EdgeInsets.only(right: 4),
              onChanged: (v) => provider.selectAll(v ?? false),
              value: selectAll ? true : (platforms.isEmpty ? false : null),
            ),
            ...PlatformType.values.map(
              (e) => _buildPlatformListItem(e, platforms[e]),
            ),
          ],
        );
      },
    );
  }

  // 构建平台列表项
  Widget _buildPlatformListItem(PlatformType type, TemplatePlatform? platform) {
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          value: platform != null,
          title: Text('- ${type.name.toUpperCase()}'),
          contentPadding: EdgeInsets.only(right: 4),
          onChanged: (v) {
            if (v == null) return;
            final platform = v ? TemplatePlatform.create(type: type) : null;
            provider.updatePlatform(type, platform);
          },
        ),
        switch (type) {
          PlatformType.android => _buildPlatformAndroidField(
            platform as TemplatePlatformAndroid?,
          ),
          PlatformType.ios => _buildPlatformIosField(
            platform as TemplatePlatformIos?,
          ),
          PlatformType.macos => _buildPlatformMacosField(
            platform as TemplatePlatformMacos?,
          ),
          _ => SizedBox(),
        },
      ],
    );
  }

  // 构建android平台参数
  Widget _buildPlatformAndroidField(TemplatePlatformAndroid? platform) {
    return Column(
      spacing: 14,
      children: [
        TextFormField(
          autofocus: true,
          initialValue: platform?.packageName,
          decoration: InputDecoration(
            labelText: '包名(PackageName)',
            hintText: '请输入包名',
          ),
          onSaved: (v) {
            if (v == null || platform == null) return;
            provider.updatePlatform(
              PlatformType.android,
              platform.copyWith(packageName: v),
            );
          },
          validator: (v) {
            if (platform != null && v?.isNotEmpty != true) return '请输入包名';
            return null;
          },
        ),
        SizedBox(),
      ],
    );
  }

  // 构建ios平台参数
  Widget _buildPlatformIosField(TemplatePlatformIos? platform) {
    return Column(
      spacing: 14,
      children: [
        TextFormField(
          autofocus: true,
          initialValue: platform?.bundleId,
          decoration: InputDecoration(
            labelText: '包名(BundleId)',
            hintText: '请输入包名',
          ),
          onSaved: (v) {
            if (v == null || platform == null) return;
            provider.updatePlatform(
              PlatformType.ios,
              platform.copyWith(bundleId: v),
            );
          },
          validator: (v) {
            if (platform != null && v?.isNotEmpty != true) return '请输入包名';
            return null;
          },
        ),
        SizedBox(),
      ],
    );
  }

  // 构建macos平台参数
  Widget _buildPlatformMacosField(TemplatePlatformMacos? platform) {
    return Column(
      spacing: 14,
      children: [
        TextFormField(
          autofocus: true,
          initialValue: platform?.bundleId,
          decoration: InputDecoration(
            labelText: '包名(BundleId)',
            hintText: '请输入包名',
          ),
          onSaved: (v) {
            if (v == null || platform == null) return;
            provider.updatePlatform(
              PlatformType.macos,
              platform.copyWith(bundleId: v),
            );
          },
          validator: (v) {
            if (platform != null && v?.isNotEmpty != true) return '请输入包名';
            return null;
          },
        ),
        SizedBox(),
      ],
    );
  }

  // 构建链接标志
  Widget _buildLinkIcon() =>
      Tooltip(message: '右侧为空时与最左侧保持一致', child: Icon(Icons.link, size: 16));
}

class TemplateCreateViewProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 项目名称/开发地址/目标路径控制器
  final projectNameController = TextEditingController(),
      devUrlController = TextEditingController(),
      targetDirController = TextEditingController();

  // 创建项目模板
  CreateTemplate _template = CreateTemplate.empty().copyWith(
    platforms: kDebugMode
        ? {
            PlatformType.android: TemplatePlatformAndroid.create(
              packageName: 'com.jtech.a',
            ),
            PlatformType.ios: TemplatePlatformIos.create(
              bundleId: 'com.jtech.i',
            ),
            PlatformType.macos: TemplatePlatformMacos.create(
              bundleId: 'com.jtech.m',
            ),
          }
        : {},
  );

  // 获取平台集合
  Map<PlatformType, TemplatePlatform> get platforms => _template.platforms;

  // 是否自动添加到项目列表
  bool addProject = true;

  TemplateCreateViewProvider(super.context) {
    // 开发模式设置测试参数
    if (kDebugMode) _initTestData();
  }

  // 初始化测试数据
  void _initTestData() async {
    final dir = await getApplicationDocumentsDirectory();
    projectNameController.text = 'jtech_test_a';
    devUrlController.text = 'http://a.b.c';
    targetDirController.text = join(dir.path, 'dev_test');
  }

  // 创建项目
  Future<void> submit() async {
    final formState = formKey.currentState;
    if (formState?.validate() != true) return;
    formState?.save();
    final result = await TemplateCreate.start(_template);
    if (result == null || !context.mounted) return;
    context.pop(addProject ? ProjectTool.getProjectInfo(result) : null);
  }

  // 选择/取消选择全部
  void selectAll(bool selectedAll) {
    _template = _template.copyWith(
      platforms: Map.from(
        selectedAll
            ? PlatformType.values.asMap().map(
                (_, v) => MapEntry(v, TemplatePlatform.create(type: v)),
              )
            : {},
      ),
    );
    notifyListeners();
  }

  // 更新自动添加到项目列表选项
  void updateAddProject(bool value) {
    addProject = value;
    notifyListeners();
  }

  // 更新指定的平台
  void updatePlatform(PlatformType type, TemplatePlatform? platform) {
    final platforms = Map<PlatformType, TemplatePlatform>.from(
      _template.platforms,
    );
    platform == null
        ? platforms.remove(type)
        : platforms.addAll({type: platform});
    _template = _template.copyWith(platforms: platforms);
    notifyListeners();
  }

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
