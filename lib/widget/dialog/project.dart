import 'package:flutter/material.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/provider/project.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/dialog/local_path.dart';
import 'package:provider/provider.dart';

/*
* 项目导入弹窗
* @author wuxubaiyang
* @Time 2023/11/27 14:19
*/
class ProjectImportDialog extends StatefulWidget {
  // 项目对象
  final Project? project;

  const ProjectImportDialog({super.key, this.project});

  // 展示弹窗
  static Future<Project?> show(BuildContext context, {Project? project}) {
    return showDialog<Project>(
      context: context,
      builder: (_) => ProjectImportDialog(
        project: project,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ProjectImportDialogState();
}

/*
* 项目导入弹窗状态
* @author wuxubaiyang
* @Time 2023/11/27 14:20
*/
class _ProjectImportDialogState extends State<ProjectImportDialog> {
  // 状态代理
  late final _provider = ProjectImportDialogProvider(widget.project);

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final isEdit = project != null;
    return ChangeNotifierProvider.value(
      value: _provider,
      builder: (context, _) {
        return AlertDialog(
          scrollable: true,
          title: Text('${isEdit ? '编辑' : '导入'}项目'),
          content: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 240),
            child: _buildForm(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => _provider.import(context, project),
              child: Text(isEdit ? '修改' : '导入'),
            ),
          ],
        );
      },
    );
  }

  // 构建表单
  Widget _buildForm(BuildContext context) {
    return Form(
      key: _provider.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _provider.labelController,
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
          ),
          const SizedBox(height: 8),
          LocalPathTextFormField(
            controller: _provider.pathController,
            label: '项目路径',
            hint: '请选择项目路径',
            validator: (v) {
              if (!ProjectTool.isPathAvailable(v!)) {
                return '路径不可用';
              }
              return null;
            },
            onPathUpdate: _provider.pathUpdate,
          ),
        ],
      ),
    );
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

  // 项目别名输入控制器
  late final TextEditingController labelController;

  // 项目路径输入控制器
  late final TextEditingController pathController;

  ProjectImportDialogProvider(Project? item)
      : _logoPath = item?.logo,
        pathController = TextEditingController(text: item?.path),
        labelController = TextEditingController(text: item?.label);

  // 当项目路径更新时调用
  Future<void> pathUpdate() async {
    final path = pathController.text;
    if (!ProjectTool.isPathAvailable(path)) return;
    if (labelController.text.isEmpty) {
      final projectName = await ProjectTool.getProjectName(path) ?? '';
      labelController.text = projectName;
    }
  }

  // 导入项目
  Future<void> import(BuildContext context, Project? project) async {
    if (!formKey.currentState!.validate()) return;
    final isEdit = project != null;
    final provider = context.read<ProjectProvider>();
  }
}
