import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'platform_item.dart';
import 'provider.dart';

/*
* 项目详情-android平台信息页
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPage
    extends ProjectPlatformPage<ProjectPlatformAndroidPageProvider> {
  const ProjectPlatformAndroidPage({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) =>
              ProjectPlatformAndroidPageProvider(context, PlatformType.android),
        ),
      ];

  @override
  List<Widget> buildPlatformItems(BuildContext context) {
    return [
      _buildLabelItem(context),
      _buildLogoItem(context),
    ];
  }

  // 构建标签项
  Widget _buildLabelItem(BuildContext context) {
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    return Selector<PlatformProvider, String?>(
      selector: (_, provider) => provider.androidInfo?.label,
      builder: (_, label, __) {
        final controller = ProjectPlatformItemController();
        final textController = TextEditingController(text: label);
        return ProjectPlatformItem.extent(
          mainAxisExtent: 140,
          crossAxisCellCount: 3,
          controller: controller,
          onReset: () {
            controller.edit(false);
            textController.text = label ?? '';
          },
          onSubmitted: () => _submitLabel(context),
          content: TextFormField(
            controller: textController,
            onChanged: (v) => controller.edit(v != label),
            onSaved: (v) => provider.updateFormData(label: v),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: '项目名',
              hintText: '请输入项目名',
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '请输入项目名';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  // 构建logo项
  ProjectPlatformItem _buildLogoItem(BuildContext context) {
    return ProjectPlatformItem.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      content: SizedBox(),
    );
  }

  // 提交label修改
  void _submitLabel(BuildContext context) {
    final provider = context.read<ProjectPlatformAndroidPageProvider>();
    Loading.show(context, loadFuture: provider.submitLabel(context))
        ?.then((_) => null)
        .catchError((e) {
      SnackTool.showMessage(context, message: '修改失败：${e.toString()}');
    });
  }
}

/*
* 项目详情-android平台信息页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 17:02
*/
class ProjectPlatformAndroidPageProvider extends ProjectPlatformProvider {
  // 表单数据
  AndroidPlatformInfoTuple _formData = (path: '', label: '', logo: []);

  ProjectPlatformAndroidPageProvider(super.context, super.platform);

  // 提交label修改
  Future<bool> submitLabel(BuildContext context) async {
    final label = _formData.label;
    final project = getProjectInfo(context);
    if (label.isEmpty || project == null) return false;
    return context
        .read<PlatformProvider>()
        .updateLabel(platform, project.path, _formData.label);
  }

  // 更新表单数据
  void updateFormData({
    String? label,
    List<PlatformLogoTuple>? logo,
  }) =>
      _formData = (
        path: '',
        label: label ?? _formData.label,
        logo: logo ?? _formData.logo,
      );
}
