import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/color_item.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/dialog/color_picker.dart';
import 'package:flutter_manager/widget/image.dart';
import 'package:flutter_manager/widget/local_path.dart';
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
      create: (_) => ProjectImportDialogProvider(project),
      builder: (context, _) {
        return CustomDialog(
          scrollable: true,
          title: Text('${isEdit ? '编辑' : '导入'}项目'),
          constraints: const BoxConstraints.tightFor(width: 260),
          content: _buildContent(context),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => context
                  .read<ProjectImportDialogProvider>()
                  .import(context, project),
              child: Text(isEdit ? '修改' : '导入'),
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
    const logoSize = Size.square(55);
    final borderRadius = BorderRadius.circular(4);
    final provider = context.read<ProjectImportDialogProvider>();
    return Selector<ProjectImportDialogProvider, String?>(
      selector: (_, provider) => provider.logoPath,
      builder: (_, logoPath, __) {
        return SizedBox.fromSize(
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
                onTap: provider.pickLogoPath,
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
        );
      },
    );
  }

  // 构建表单项-项目别名
  Widget _buildFormFieldLabel(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return TextFormField(
      controller: provider.labelController,
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
    return LocalPathTextFormField(
      label: '项目路径',
      hint: '请选择项目路径',
      onPathUpdate: provider.pathUpdate,
      controller: provider.pathController,
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
    return Selector<EnvironmentProvider, List<Environment>>(
      selector: (_, provider) => provider.environments,
      builder: (_, environments, __) {
        return Selector<ProjectImportDialogProvider, Environment?>(
          selector: (_, provider) => provider.environment,
          builder: (_, current, __) {
            return DropdownButtonFormField<Environment>(
              value: current,
              hint: const Text('请选择环境'),
              onChanged: provider.environmentUpdate,
              validator: (value) {
                if (value == null) {
                  return '请选择环境';
                }
                return null;
              },
              items: environments
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.title),
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }

  // 内容填充
  final _contentPadding = const EdgeInsets.only(right: 4);

  // 构建表单项-颜色
  Widget _buildFormFieldColor(BuildContext context) {
    return Selector<ProjectImportDialogProvider, Color>(
      selector: (_, provider) => provider.color,
      builder: (_, color, __) {
        return ListTile(
          title: const Text('颜色'),
          contentPadding: _contentPadding,
          trailing: ColorPickerItem(
            size: 30,
            color: color,
            isSelected: true,
            onPressed: () => _showColorPicker(context, color),
          ),
          onTap: () => _showColorPicker(context, color),
        );
      },
    );
  }

  // 构建表单项-置顶
  Widget _buildFormFieldPinned(BuildContext context) {
    final provider = context.read<ProjectImportDialogProvider>();
    return Selector<ProjectImportDialogProvider, bool>(
      selector: (_, provider) => provider.pinned,
      builder: (_, pinned, __) {
        return CheckboxListTile(
          value: pinned,
          title: const Text('置顶'),
          contentPadding: _contentPadding,
          onChanged: provider.pinnedUpdate,
        );
      },
    );
  }

  // 展示颜色选择器
  Future<void> _showColorPicker(BuildContext context, Color? color) {
    final provider = context.read<ProjectImportDialogProvider>();
    return ColorPickerDialog.show(
      context,
      current: color,
      useTransparent: true,
      colors: Colors.primaries,
    ).then(provider.colorUpdate);
  }
}

/*
* 项目导入弹窗状态管理类
* @author wuxubaiyang
* @Time 2023/11/27 14:25
*/
class ProjectImportDialogProvider extends ChangeNotifier {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 项目图标路径
  String? _logoPath;

  // 获取项目图标路径
  String get logoPath => _logoPath ?? '';

  // 项目是否置顶
  bool? _pinned;

  // 获取项目是否置顶
  bool get pinned => _pinned ?? false;

  // 所选环境信息
  Environment? _environment;

  // 获取所选环境信息
  Environment? get environment => _environment;

  // 项目颜色
  Color? _color;

  // 获取项目颜色
  Color get color => _color ?? Colors.transparent;

  // 项目别名输入控制器
  late final TextEditingController labelController;

  // 项目路径输入控制器
  late final TextEditingController pathController;

  ProjectImportDialogProvider(Project? item)
      : _logoPath = item?.logo,
        _pinned = item?.pinned,
        _color = Color(item?.color ?? Colors.transparent.value),
        pathController = TextEditingController(text: item?.path),
        labelController = TextEditingController(text: item?.label) {
    if (item != null && item.envId >= 0) {
      database.getEnvironmentById(item.envId).then((env) {
        environmentUpdate(env);
      });
    } else {
      database.getEnvironmentList(orderDesc: true).then((envs) {
        if (envs.isNotEmpty) environmentUpdate(envs.first);
      });
    }
  }

  // 导入项目
  Future<void> import(BuildContext context, Project? project) async {
    if (!formKey.currentState!.validate()) return;
    final isEdit = project != null;
    final provider = context.read<ProjectProvider>();
    Loading.show<Project?>(context,
        loadFuture: provider.update(
          Project()
            ..label = labelController.text
            ..path = pathController.text
            ..logo = _logoPath ?? ''
            ..envId = _environment?.id ?? 0
            ..color = color.value
            ..pinned = pinned,
        ))?.then((result) {
      Navigator.pop(context, result);
    }).catchError((e) {
      final message = '${isEdit ? '修改' : '导入'}失败：$e';
      SnackTool.showMessage(context, message: message);
    });
  }

  // 选择项目图标路径
  Future<void> pickLogoPath() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      lockParentWindow: true,
      dialogTitle: '选择项目图',
      initialDirectory: pathController.text,
    );
    logoUpdate(result?.files.firstOrNull?.path);
  }

  // 项目图标更新
  void logoUpdate(String? value) {
    if (value == null) return;
    _logoPath = value;
    notifyListeners();
  }

  // 当项目路径更新时调用
  Future<void> pathUpdate() async {
    final path = pathController.text;
    final project = await ProjectTool.getProjectInfo(path);
    if (project == null) return;
    labelController.text = project.label;
    logoUpdate(project.logo);
  }

  // 项目置顶状态更新
  void pinnedUpdate(bool? value) {
    if (value == null) return;
    _pinned = value;
    notifyListeners();
  }

  // 项目颜色更新
  void colorUpdate(Color? value) {
    if (value == null) return;
    _color = value;
    notifyListeners();
  }

  // 项目环境更新
  void environmentUpdate(Environment? value) {
    if (value == null) return;
    _environment = value;
    notifyListeners();
  }
}
