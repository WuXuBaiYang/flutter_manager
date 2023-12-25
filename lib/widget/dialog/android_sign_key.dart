import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 展示android签名创建弹窗
Future<bool?> showAndroidSignKey(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AndroidSignKeyDialog(),
  );
}

/*
* android签名创建弹窗
* @author wuxubaiyang
* @Time 2023/12/15 9:00
*/
class AndroidSignKeyDialog extends ProviderView {
  const AndroidSignKeyDialog({super.key});

  @override
  List<SingleChildWidget> loadProviders(BuildContext context) => [
        ChangeNotifierProvider<AndroidSignKeyDialogProvider>(
          create: (_) => AndroidSignKeyDialogProvider(context),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('创建Android签名'),
      content: _buildContent(context),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {},
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return SingleChildScrollView(
      child: Form(
        key: provider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKeytoolPath(context),
            _buildOutputPath(context),
            _buildAlias(context),
            _buildStorepass(context),
            _buildKeypass(context),
          ].expand((e) => [e, const SizedBox(height: 8)]).toList()
            ..removeLast(),
        ),
      ),
    );
  }

  // 构建keytool路径输入框
  Widget _buildKeytoolPath(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return LocalPathFormField(
      label: 'keytool路径',
      hint: '请选择keytool路径',
      controller: provider.keytoolPathController,
      onSaved: (v) => provider.updateSignKeyInfo(keytool: v),
    );
  }

  // 构建输出路径输入框
  Widget _buildOutputPath(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return LocalPathFormField(
      label: '输出路径',
      hint: '请选择输出路径',
      initialValue: provider.signKeyInfo?.path,
      onSaved: (v) => provider.updateSignKeyInfo(path: v),
    );
  }

  // 构建签名别名输入框
  Widget _buildAlias(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '签名别名',
        hintText: '请输入签名别名',
      ),
      initialValue: provider.signKeyInfo?.alias,
      onSaved: (v) => provider.updateSignKeyInfo(alias: v),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入签名别名';
        return null;
      },
    );
  }

  // 构建storepass输入框
  Widget _buildStorepass(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '存储库密码',
        hintText: '请输入存储库密码',
      ),
      initialValue: provider.signKeyInfo?.storepass,
      onSaved: (v) => provider.updateSignKeyInfo(storepass: v),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入存储库密码';
        return null;
      },
    );
  }

  // 构建keypass输入框
  Widget _buildKeypass(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '密钥密码',
        hintText: '请输入密钥密码',
      ),
      initialValue: provider.signKeyInfo?.keypass,
      onSaved: (v) => provider.updateSignKeyInfo(keypass: v),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入密钥密码';
        return null;
      },
    );
  }
}

/*
* android签名创建弹窗提供器类
* @author wuxubaiyang
* @Time 2023/12/25 16:45
*/
class AndroidSignKeyDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 表单数据
  AndroidSignKeyForm? _signKeyInfo;

  // 表单数据
  AndroidSignKeyForm? get signKeyInfo => _signKeyInfo;

  // keytool路径输入控制器
  final keytoolPathController = TextEditingController();

  AndroidSignKeyDialogProvider(super.context) {
    // 初始化获取keytool路径
    _updateKeytoolPath();
  }

  // 更新keytool路径
  Future<void> _updateKeytoolPath() async {
    final path = await ProjectTool.getJavaKeyToolPath();
    if (path == null) return;
    keytoolPathController.text = path;
  }

  // 更新表单数据(copyWith)
  void updateSignKeyInfo({
    String? keytool,
    String? path,
    String? alias,
    String? storepass,
    int? keySize,
    String? keypass,
    String? keyAlg,
    String? validity,
    String? dNameCN,
    String? dNameOU,
    String? dNameO,
    String? dNameL,
    String? dNameT,
    String? dNameC,
  }) {
    _signKeyInfo = (
      keytool: keytool ?? _signKeyInfo?.keytool ?? '',
      path: path ?? _signKeyInfo?.path ?? '',
      alias: alias ?? _signKeyInfo?.alias ?? '',
      storepass: storepass ?? _signKeyInfo?.storepass ?? '',
      keySize: keySize ?? _signKeyInfo?.keySize ?? 2048,
      keypass: keypass ?? _signKeyInfo?.keypass ?? '',
      keyAlg: keyAlg ?? _signKeyInfo?.keyAlg ?? '',
      validity: validity ?? _signKeyInfo?.validity ?? '',
      dNameCN: dNameCN ?? _signKeyInfo?.dNameCN ?? '',
      dNameOU: dNameOU ?? _signKeyInfo?.dNameOU ?? '',
      dNameO: dNameO ?? _signKeyInfo?.dNameO ?? '',
      dNameL: dNameL ?? _signKeyInfo?.dNameL ?? '',
      dNameT: dNameT ?? _signKeyInfo?.dNameT ?? '',
      dNameC: dNameC ?? _signKeyInfo?.dNameC ?? '',
    );
  }
}
