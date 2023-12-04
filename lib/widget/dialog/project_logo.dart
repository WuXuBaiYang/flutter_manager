import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/image.dart';
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
          constraints: const BoxConstraints.tightForFinite(width: 450),
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
          _buildFormFieldPlatforms(context),
        ],
      ),
    );
  }

  // 构建图标选择
  Widget _buildFormFieldLogo(BuildContext context) {
    const logoSize = Size.square(55);
    final borderRadius = BorderRadius.circular(4);
    final provider = context.read<ProjectLogoDialogProvider>();
    return FormField<String>(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择图标';
        }
        return null;
      },
      onSaved: (v) => provider.updateFormData(logoPath: v),
      builder: (field) {
        final logoPath = field.value;
        return InputDecorator(
          decoration: InputDecoration(
            border: InputBorder.none,
            errorText: field.errorText,
          ),
          child: Center(
            child: SizedBox.fromSize(
              size: logoSize,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: borderRadius,
                  ),
                  child: InkWell(
                    borderRadius: borderRadius,
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        lockParentWindow: true,
                        dialogTitle: '选择项目图标',
                      );
                      field.didChange(result?.files.firstOrNull?.path);
                    },
                    child: logoPath?.isNotEmpty == true
                        ? ImageView.file(
                      File(logoPath ?? ''),
                      fit: BoxFit.cover,
                      size: logoSize.shortestSide,
                    )
                        : const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建展开列表
  Widget _buildFormFieldPlatforms(BuildContext context) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return FormField<List<PlatformType>>(
      initialValue: platformLogoMap.keys.toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择平台';
        }
        return null;
      },
      onSaved: (v) => provider.updateFormData(platforms: v),
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            border: InputBorder.none,
            errorText: field.errorText,
          ),
          child: Selector<ProjectLogoDialogProvider, PlatformType?>(
            selector: (_, provider) => provider.expandedPlatform,
            builder: (_, expandedPlatform, __) {
              return ExpansionPanelList.radio(
                materialGapSize: 8,
                initialOpenPanelValue: expandedPlatform,
                expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
                expansionCallback: (index, isExpanded) => context
                    .read<ProjectLogoDialogProvider>()
                    .updateExpandedPlatform(
                      isExpanded ? null : platformLogoMap.keys.elementAt(index),
                    ),
                children: List.generate(platformLogoMap.length, (i) {
                  final item = platformLogoMap.entries.elementAt(i);
                  return _buildExpansionPanelItem(context, item, field);
                }),
              );
            },
          ),
        );
      },
    );
  }

  // 构建展开项
  ExpansionPanelRadio _buildExpansionPanelItem(
    BuildContext context,
    MapEntry<PlatformType, List<PlatformLogoTuple>> item,
    FormFieldState<List<PlatformType>> field,
  ) {
    return ExpansionPanelRadio(
      value: item.key,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Tooltip(
            message: '替换该平台',
            child: Checkbox(
              isError: field.hasError,
              value: field.value?.contains(item.key) ?? false,
              onChanged: (v) {
                final temp = field.value ?? [];
                v == true ? temp.add(item.key) : temp.remove(item.key);
                field.didChange(temp);
              },
            ),
          ),
          title: Text(item.key.name),
          trailing: Tooltip(
            message: '图标数量',
            child: Text('${item.value.length}'),
          ),
        );
      },
      body: ProjectLogoGrid(
        logoList: item.value,
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

  // 当前展开平台
  PlatformType? _expandedPlatform;

  // 当前展开平台
  PlatformType? get expandedPlatform => _expandedPlatform;

  // 缓存表单值
  ProjectLogoDialogResultTuple _formData = (logoPath: '', platforms: []);

  // 更新展开平台
  void updateExpandedPlatform(PlatformType? platform) {
    _expandedPlatform = platform;
    notifyListeners();
  }

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
