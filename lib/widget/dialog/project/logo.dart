import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/form_field/project_logo.dart';
import 'package:flutter_manager/widget/form_field/project_logo_panel.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示修改图标弹窗
Future<ProjectLogoDialogForm?> showProjectLogo(BuildContext context,
    {required Map<PlatformType, List<PlatformLogo>> logoMap}) async {
  return showDialog<ProjectLogoDialogForm>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectLogoDialog(
      logoMap: logoMap,
    ),
  );
}

/*
* 项目修改图标弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLogoDialog extends ProviderView<ProjectLogoDialogProvider> {
  // 平台与图标表
  final Map<PlatformType, List<PlatformLogo>> logoMap;

  ProjectLogoDialog({super.key, required this.logoMap});

  @override
  ProjectLogoDialogProvider createProvider(context) =>
      ProjectLogoDialogProvider(context, logoMap);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('图标'),
      content: _buildContent(context),
      style: CustomDialogStyle(
        constraints: BoxConstraints(minWidth: 380, maxHeight: 320),
      ),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: provider.submit,
          child: const Text('确定'),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return EmptyBoxView(
      hint: '暂无可用平台',
      isEmpty: logoMap.isEmpty,
      child: Form(
        key: provider.formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            _buildFieldLogo(context),
            const SizedBox(height: 14),
            _buildFieldPlatforms(context),
          ]),
        ),
      ),
    );
  }

  // 构建图标选择
  Widget _buildFieldLogo(BuildContext context) {
    return ProjectLogoFormField(
      logoSize: const Size.square(100),
      onSaved: (v) => provider.updateFormData(logo: v),
    );
  }

  // 构建展开列表
  Widget _buildFieldPlatforms(BuildContext context) {
    return ProjectLogoPanelFormField(
      platformLogoMap: logoMap,
      onSaved: (v) => provider.updateFormData(platforms: v?.platforms),
      initialValue: (expanded: null, platforms: provider.formData.platforms),
    );
  }
}

// 项目修改图标弹窗表单数据元组
typedef ProjectLogoDialogForm = ({
  String logo,
  List<PlatformType> platforms,
});

/*
* 项目修改图标弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 15:26
*/
class ProjectLogoDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  ProjectLogoDialogProvider(
      super.context, Map<PlatformType, List<PlatformLogo>> logoMap)
      : _formData = (logo: '', platforms: logoMap.keys.toList());

  // 表单数据
  ProjectLogoDialogForm _formData;

  // 获取表单数据
  ProjectLogoDialogForm get formData => _formData;

  // 验证表单并返回
  Future<ProjectLogoDialogForm?> submit() async {
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      context.pop(_formData);
      return _formData;
    } catch (e) {
      showNoticeError(e.toString(), title: '操作失败');
    }
    return null;
  }

  // 更新表单数据
  void updateFormData({
    String? logo,
    List<PlatformType>? platforms,
  }) {
    _formData = (
      logo: logo ?? _formData.logo,
      platforms: platforms ?? _formData.platforms,
    );
  }
}
