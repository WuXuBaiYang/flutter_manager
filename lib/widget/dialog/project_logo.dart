import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/form_field/project_logo.dart';
import 'package:flutter_manager/widget/form_field/project_logo_panel.dart';
import 'package:provider/provider.dart';

// 展示修改图标弹窗
Future<ProjectLogoDialogFormTuple?> showProjectLogo(BuildContext context,
    {required Map<PlatformType, List<PlatformLogoTuple>>
        platformLogoMap}) async {
  return showDialog<ProjectLogoDialogFormTuple>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectLogoDialog(
      platformLogoMap: platformLogoMap,
    ),
  );
}

/*
* 项目修改图标弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLogoDialog extends StatelessWidget {
  // 平台与图标表
  final Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap;

  const ProjectLogoDialog({super.key, required this.platformLogoMap});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectLogoDialogProvider(context, platformLogoMap),
      builder: (context, _) {
        final provider = context.watch<ProjectLogoDialogProvider>();
        return CustomDialog(
          title: const Text('图标'),
          content: _buildContent(context),
          constraints: BoxConstraints.tightFor(
              width: 380, height: platformLogoMap.isEmpty ? 280 : null),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () => provider.submitForm(context).then((result) {
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
    return EmptyBoxView(
      hint: '暂无可用平台',
      isEmpty: platformLogoMap.isEmpty,
      child: Form(
        key: context.read<ProjectLogoDialogProvider>().formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildFormFieldLogo(context),
              const SizedBox(height: 14),
              _buildFormFieldPlatforms(context),
            ],
          ),
        ),
      ),
    );
  }

  // 构建图标选择
  Widget _buildFormFieldLogo(BuildContext context) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return ProjectLogoFormField(
      logoSize: const Size.square(100),
      onSaved: (v) => provider.updateFormData(logo: v),
    );
  }

  // 构建展开列表
  Widget _buildFormFieldPlatforms(BuildContext context) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return ProjectLogoPanelFormField(
      platformLogoMap: platformLogoMap,
      onSaved: (v) => provider.updateFormData(platforms: v?.platforms),
      initialValue: (expanded: null, platforms: provider.formData.platforms),
    );
  }
}

// 项目修改图标弹窗表单数据元组
typedef ProjectLogoDialogFormTuple = ({
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

  // 表单数据
  ProjectLogoDialogFormTuple _formData = (logo: '', platforms: []);

  // 获取表单数据
  ProjectLogoDialogFormTuple get formData => _formData;

  ProjectLogoDialogProvider(super.context,
      Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap) {
    updateFormData(platforms: platformLogoMap.keys.toList());
  }

  // 验证表单并返回
  Future<ProjectLogoDialogFormTuple?> submitForm(BuildContext context) async {
    try {
      final formState = formKey.currentState;
      if (!(formState?.validate() ?? false)) return null;
      formState!.save();
      return _formData;
    } catch (e) {
      showError(e.toString(), title: '操作失败');
    }
    return null;
  }

  // 更新表单数据
  void updateFormData({String? logo, List<PlatformType>? platforms}) =>
      _formData = (
        logo: logo ?? _formData.logo,
        platforms: platforms ?? _formData.platforms,
      );
}
