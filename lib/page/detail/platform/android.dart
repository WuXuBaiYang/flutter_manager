import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_manager/page/detail/platform/base.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:flutter_manager/widget/dialog/image_editor.dart';
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
    return Selector<PlatformProvider, String>(
      selector: (_, provider) => provider.androidInfo?.label ?? '',
      builder: (_, label, __) {
        final controller = ProjectPlatformItemController();
        final textController = TextEditingController(text: label);
        return ProjectPlatformItem.extent(
          mainAxisExtent: 140,
          crossAxisCellCount: 3,
          controller: controller,
          onReset: () {
            controller.edit(false);
            textController.text = label;
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
  Widget _buildLogoItem(BuildContext context) {
    return Selector<PlatformProvider, AndroidPlatformInfoTuple?>(
      selector: (_, provider) => provider.androidInfo,
      builder: (_, androidInfo, __) {
        final logos = androidInfo?.logo ?? [];
        return ProjectPlatformItem.extent(
          crossAxisCellCount: 5,
          mainAxisExtent: (logos.length % 5 + 1) * 140,
          content: Row(
            children: [
              Expanded(child: ProjectLogoGrid(logoList: logos)),
              IconButton.outlined(
                tooltip: '选择项目图标',
                icon: const Icon(Icons.add),
                onPressed: () => _replaceLogo(context),
              ),
              const SizedBox(width: 4),
            ],
          ),
        );
      },
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

  // 替换logo
  void _replaceLogo(BuildContext context) async {
    final provider = context.read<PlatformProvider>();
    final project = context
        .read<ProjectPlatformAndroidPageProvider>()
        .getProjectInfo(context);
    if (project == null) return;
    Tool.pickImageWithEdit(
      context,
      dialogTitle: '选择项目图标',
      absoluteRatio: CropAspectRatio.ratio1_1,
    ).then((result) {
      if (result == null) return;
      final controller = StreamController<double>();
      final future = provider.updateLogo(
          PlatformType.android, project.path, result,
          progressCallback: (c, t) => controller.add(c / t));
      Loading.show(
        context,
        loadFuture: future,
        progressStream: controller.stream,
      )?.then((_) => null).catchError((e) {
        SnackTool.showMessage(context, message: '修改失败：${e.toString()}');
      });
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
  void updateFormData({String? label}) => _formData = (
        path: _formData.path,
        label: label ?? _formData.label,
        logo: _formData.logo,
      );
}
