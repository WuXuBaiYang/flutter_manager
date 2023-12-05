import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/form_field/project_logo.dart';
import 'package:flutter_manager/widget/form_field/project_logo_panel.dart';
import 'package:provider/provider.dart';

/*
* 项目修改图标弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLogoDialog extends StatelessWidget {
  // 平台与图标表
  final Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap;

  const ProjectLogoDialog({super.key, required this.platformLogoMap});

  // 展示弹窗
  static Future<ProjectLogoDialogFormTuple?> show(BuildContext context,
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectLogoDialogProvider(platformLogoMap),
      builder: (context, _) {
        final provider = context.read<ProjectLogoDialogProvider>();
        return CustomDialog(
          title: const Text('图标'),
          content: _buildContent(context),
          constraints: BoxConstraints.tightFor(
              width: 380, height: platformLogoMap.isEmpty ? 280 : null),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () => provider.submitForm(context).then((result) {
                if (result != null) Navigator.pop(context, result);
              }).catchError((e) {
                SnackTool.showMessage(context, message: '操作失败：${e.toString()}');
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

  ProjectLogoDialogProvider(
      Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap) {
    updateFormData(platforms: platformLogoMap.keys.toList());
  }

  // 更新表单数据
  void updateFormData({
    String? logo,
    List<PlatformType>? platforms,
  }) =>
      _formData = (
        logo: logo ?? _formData.logo,
        platforms: platforms ?? _formData.platforms,
      );

  // 验证表单并返回
  Future<ProjectLogoDialogFormTuple?> submitForm(BuildContext context) async {
    final formState = formKey.currentState;
    if (!(formState?.validate() ?? false)) return null;
    formState!.save();
    return _formData;
  }
}
