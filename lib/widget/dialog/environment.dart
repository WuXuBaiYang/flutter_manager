import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
class EnvironmentLocalImportDialog extends StatefulWidget {
  // 环境对象
  final Environment? environment;

  const EnvironmentLocalImportDialog({super.key, this.environment});

  // 展示弹窗
  static Future<void> show(BuildContext context,
      {Environment? environment}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => EnvironmentLocalImportDialog(
        environment: environment,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _EnvironmentLocalImportDialogState();
}

/*
* 环境导入弹窗状态管理类
* @author wuxubaiyang
* @Time 2023/11/26 10:17
*/
class _EnvironmentLocalImportDialogState
    extends State<EnvironmentLocalImportDialog> {
  // 表单key
  final _formKey = GlobalKey<FormState>();

  // 本地路径选择输入框控制器
  late final _localPathController = TextEditingController(
    text: widget.environment?.path ?? '',
  );

  // 判断是否为编辑模式
  bool get _isEdit => widget.environment != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('${_isEdit ? '编辑' : '导入'}本地环境'),
      content: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 300),
        child: _buildForm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final provider = context.read<EnvironmentProvider>();
            final path = _localPathController.text;
            final future = _isEdit
                ? provider.refreshEnvironment(widget.environment!..path = path)
                : provider.importEnvironment(path);
            Loading.show(context, loadFuture: future)?.then((_) {
              SnackTool.show(context,
                  child: Text('${_isEdit ? '修改' : '导入'}成功'));
              Navigator.pop(context);
            }).catchError((e) {
              SnackTool.show(context,
                  child: Text('${_isEdit ? '修改' : '导入'}失败：$e'));
            });
          },
          child: Text(_isEdit ? '修改' : '导入'),
        ),
      ],
    );
  }

  // 构建表单
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _localPathController,
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
                onPressed: _importLocalPath,
                icon: const Icon(Icons.folder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 导入本地路径
  void _importLocalPath() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
      dialogTitle: '请选择flutter路径',
      initialDirectory: _localPathController.text,
    );
    if (dir == null) return;
    _localPathController.text = dir;
  }
}
