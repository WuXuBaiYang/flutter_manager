import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:flutter_manager/widget/form_field/local_path.dart';
import 'package:jtech_base/jtech_base.dart';
import 'create_options.dart';

// 展示android签名创建弹窗
Future<bool?> showCreateAndroidSign(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CreateAndroidSignDialog(),
  );
}

/*
* android签名创建弹窗
* @author wuxubaiyang
* @Time 2023/12/15 9:00
*/
class CreateAndroidSignDialog
    extends ProviderView<AndroidSignKeyDialogProvider> {
  CreateAndroidSignDialog({super.key});

  @override
  AndroidSignKeyDialogProvider createProvider(BuildContext context) =>
      AndroidSignKeyDialogProvider(context);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('创建Android签名'),
      content: _buildContent(context),
      actions: <Widget>[
        TextButton(
          onPressed: context.pop,
          child: const Text('取消'),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () => provider.submit().loading(context),
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: provider.formKey,
        child: createSelector< bool>(
          selector: (_, provider) => provider.samePass,
          builder: (_, samePass, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildKeytoolField(context),
                _buildOutputField(context),
                _buildAliasField(context),
                _buildStorepassField(context, samePass),
                if (!samePass) _buildKeypassField(context),
                _buildOptionFields(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // 构建keytool路径输入框
  Widget _buildKeytoolField(BuildContext context) {
    return LocalPathFormField(
      label: 'keytool所在目录',
      hint: '请选择keytool所在目录',
      controller: provider.keytoolPathController,
      onSaved: (v) => provider.updateSignKeyInfo(keytoolPath: v),
    );
  }

  // 构建输出路径输入框
  Widget _buildOutputField(BuildContext context) {
    return LocalPathFormField(
      label: '输出路径',
      hint: '请选择输出路径',
      initialValue: provider.signKeyInfo?.path,
      onSaved: (v) => provider.updateSignKeyInfo(path: v),
    );
  }

  // 构建签名别名输入框
  Widget _buildAliasField(BuildContext context) {
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
  Widget _buildStorepassField(BuildContext context, bool samePass) {
    final label = '存储库${samePass ? '/密钥' : ''}密码';
    return TextFormField(
      initialValue: provider.signKeyInfo?.storepass,
      onSaved: (v) => provider.updateSignKeyInfo(storepass: v, keypass: v),
      decoration: InputDecoration(
        labelText: label,
        hintText: '请输入$label',
        suffixIcon: IconButton(
          icon: Icon(samePass ? Icons.link_off_rounded : Icons.link_rounded),
          onPressed: provider.toggleSamePass,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入$label';
        return null;
      },
    );
  }

  // 构建keypass输入框
  Widget _buildKeypassField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '密钥密码',
        hintText: '请输入密钥密码',
      ),
      initialValue: provider.signKeyInfo?.keypass,
      onSaved: (v) {
        if (provider.samePass) return;
        provider.updateSignKeyInfo(keypass: v);
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入密钥密码';
        return null;
      },
    );
  }

  // 构建可选表单项（折叠）
  Widget _buildOptionFields(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('其他可选参数'),
      children: [CreateAndroidSignOptions()],
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

  // keytool路径输入控制器
  final keytoolPathController = TextEditingController();

  AndroidSignKeyDialogProvider(super.context) {
    updateSignKeyInfo();
    _updateKeytoolPath();
  }

  // 是否使用同一个密码
  bool _samePass = true;

  // 判断是否使用同一个密码
  bool get samePass => _samePass;

  // 表单数据
  AndroidSignKeyForm? _signKeyInfo;

  // 表单数据
  AndroidSignKeyForm? get signKeyInfo => _signKeyInfo;

  // 更新keytool路径
  Future<void> _updateKeytoolPath() async {
    final path = await ProjectTool.getJavaKeyToolPath();
    if (path == null) return;
    keytoolPathController.text = path;
    updateSignKeyInfo(keytoolPath: path);
  }

  // 提交表单
  Future<bool> submit() async {
    try {
      final currentState = formKey.currentState;
      if (currentState == null || !currentState.validate()) return false;
      currentState.save();
      if (signKeyInfo == null) return false;
      final result = await ProjectTool.genAndroidSignKey(signKeyInfo!);
      if (result && context.mounted) context.pop(result);
      return result;
    } catch (e) {
      showNoticeError(e.toString(), title: '签名生成失败');
    }
    return false;
  }

  // 更新是否使用同一个密码
  void toggleSamePass() {
    _samePass = !samePass;
    notifyListeners();
  }

  // 更新表单数据(copyWith)
  void updateSignKeyInfo({
    String? keytoolPath,
    String? path,
    String? alias,
    String? storepass,
    String? keypass,
    String? keyAlg,
    int? keySize,
    int? validity,
    String? dNameCN,
    String? dNameOU,
    String? dNameO,
    String? dNameL,
    String? dNameT,
    String? dNameC,
  }) {
    _signKeyInfo = (
      keytoolPath: keytoolPath ?? _signKeyInfo?.keytoolPath ?? '',
      path: path ?? _signKeyInfo?.path ?? '',
      alias: alias ?? _signKeyInfo?.alias ?? '',
      storepass: storepass ?? _signKeyInfo?.storepass ?? '',
      keypass: keypass ?? _signKeyInfo?.keypass ?? '',
      keyAlg: keyAlg ?? _signKeyInfo?.keyAlg ?? 'RSA',
      keySize: keySize ?? _signKeyInfo?.keySize ?? 2048,
      validity: validity ?? _signKeyInfo?.validity ?? 99 * 365,
      dNameCN: dNameCN ?? _signKeyInfo?.dNameCN ?? '',
      dNameOU: dNameOU ?? _signKeyInfo?.dNameOU ?? '',
      dNameO: dNameO ?? _signKeyInfo?.dNameO ?? '',
      dNameL: dNameL ?? _signKeyInfo?.dNameL ?? '',
      dNameT: dNameT ?? _signKeyInfo?.dNameT ?? '',
      dNameC: dNameC ?? _signKeyInfo?.dNameC ?? '',
    );
    notifyListeners();
  }
}
