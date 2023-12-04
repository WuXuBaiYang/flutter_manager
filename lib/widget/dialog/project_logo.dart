import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:flutter_manager/widget/form/project_logo.dart';
import 'package:flutter_manager/widget/form/project_logo_panel.dart';
import 'package:provider/provider.dart';

// 批量修改图标弹窗返回值元组
typedef ProjectLogoDialogResultTuple = ({
  String logoPath,
  List<PlatformType> platforms,
});

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
  static Future<ProjectLogoDialogResultTuple?> show(BuildContext context,
      {required Map<PlatformType, List<PlatformLogoTuple>>
          platformLogoMap}) async {
    return showDialog<ProjectLogoDialogResultTuple>(
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
      create: (_) => ProjectLogoDialogProvider(),
      builder: (context, _) {
        return CustomDialog(
          scrollable: true,
          title: const Text('图标'),
          content: _buildContent(context),
          constraints: const BoxConstraints.tightForFinite(width: 380),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () =>
                  context.read<ProjectLogoDialogProvider>().submitForm(context),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Form(
      key: context.read<ProjectLogoDialogProvider>().formKey,
      child: Column(
        children: [
          _buildFormFieldLogo(context),
          const SizedBox(height: 14),
          _buildFormFieldPlatforms(context),
        ],
      ),
    );
  }

  // 构建图标选择
  Widget _buildFormFieldLogo(BuildContext context) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return ProjectLogoFormField(
      logoSize: const Size.square(100),
      onSaved: (v) => provider.updateFormData(logoPath: v),
    );
  }

  // 构建展开列表
  Widget _buildFormFieldPlatforms(BuildContext context) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return ProjectLogoPanelFormField(
      platformLogoMap: platformLogoMap,
      onSaved: (v) => provider.updateFormData(platforms: v?.platforms),
      initialValue: (
      expanded: null,
      platforms: platformLogoMap.keys.toList()
      ),
    );
  }
}

/*
* 项目修改图标弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 15:26
*/
class ProjectLogoDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 缓存表单值
  ProjectLogoDialogResultTuple _formData = (logoPath: '', platforms: []);

  // 更新表单值
  void updateFormData({String? logoPath, List<PlatformType>? platforms}) =>
      _formData = (
        logoPath: logoPath ?? _formData.logoPath,
        platforms: platforms ?? _formData.platforms,
      );

  // 验证表单并返回
  bool submitForm(BuildContext context) {
    final formState = formKey.currentState;
    if (!(formState?.validate() ?? false)) return false;
    formState!.save();
    Navigator.pop(context, _formData);
    return true;
  }
}
