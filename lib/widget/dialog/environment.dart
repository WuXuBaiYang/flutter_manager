import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:provider/provider.dart';

/*
* 环境导入弹窗
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class EnvironmentImportDialog extends StatefulWidget {
  // 环境对象
  final Environment? environment;

  const EnvironmentImportDialog({super.key, this.environment});

  // 展示弹窗
  static Future<void> show(BuildContext context,
      {Environment? environment}) async {
    return showDialog<void>(
      context: context,
      builder: (_) => EnvironmentImportDialog(
        environment: environment,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _EnvironmentImportDialogState();
}

/*
* 环境导入弹窗状态管理类
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class _EnvironmentImportDialogState extends State<EnvironmentImportDialog> {
  // 状态代理
  late final _provider =
      EnvironmentImportDialogProvider(widget.environment?.path);

  @override
  Widget build(BuildContext context) {
    final environment = widget.environment;
    final isEdit = environment != null;
    return ChangeNotifierProvider.value(
      value: _provider,
      builder: (context, _) {
        return AlertDialog(
          scrollable: true,
          title: Text('${isEdit ? '编辑' : '导入'}环境'),
          content: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 300),
            child: _buildForm(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => _provider.import(context, environment),
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
        children: [
          TextFormField(
            controller: _provider.localPathController,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return '路径不能为空';
              }
              if (!EnvironmentTool.isPathAvailable(v)) {
                return '路径不可用';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'flutter路径',
              hintText: '请选择flutter路径',
              suffixIcon: IconButton(
                onPressed: _provider.importLocalPath,
                icon: const Icon(Icons.folder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
* 环境导入弹窗状态管理
* @author wuxubaiyang
* @Time 2023/11/26 16:11
*/
class EnvironmentImportDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 本地路径选择输入框控制器
  late TextEditingController localPathController;

  EnvironmentImportDialogProvider(String? initialPath)
      : localPathController = TextEditingController(text: initialPath);

  // 导入环境
  Future<void> import(BuildContext context, Environment? environment) async {
    if (!formKey.currentState!.validate()) return;
    final path = localPathController.text;
    final isEdit = environment != null;
    final provider = context.read<EnvironmentProvider>();
    final future = isEdit
        ? provider.refreshEnvironment(environment..path = path)
        : provider.importEnvironment(path);
    Loading.show(context, loadFuture: future)?.then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      SnackTool.show(context, child: Text('${isEdit ? '修改' : '导入'}失败：$e'));
    });
  }

  // 导入本地路径
  Future<void> importLocalPath() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
      dialogTitle: '请选择flutter路径',
      initialDirectory: localPathController.text,
    );
    if (dir == null) return;
    localPathController.text = dir;
  }
}
