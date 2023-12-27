import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/common/view.dart';
import 'package:flutter_manager/tool/loading.dart';
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
    final provider = context.read<AndroidSignKeyDialogProvider>();
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
          onPressed: () =>
              provider.submitForm().loading(context).then((result) {
            if (result == true) Navigator.pop(context);
          }),
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
        child: Selector<AndroidSignKeyDialogProvider, bool>(
          selector: (_, provider) => provider.samePass,
          builder: (_, samePass, __) {
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
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return LocalPathFormField(
      label: 'keytool路径',
      pickDirectory: false,
      hint: '请选择keytool路径',
      controller: provider.keytoolPathController,
      onSaved: (v) => provider.updateSignKeyInfo(keytool: v),
    );
  }

  // 构建输出路径输入框
  Widget _buildOutputField(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return LocalPathFormField(
      label: '输出路径',
      hint: '请选择输出路径',
      initialValue: provider.signKeyInfo?.path,
      onSaved: (v) => provider.updateSignKeyInfo(path: v),
    );
  }

  // 构建签名别名输入框
  Widget _buildAliasField(BuildContext context) {
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
  Widget _buildStorepassField(BuildContext context, bool samePass) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    final label = '存储库${samePass ? '/密钥' : ''}密码';
    return TextFormField(
      initialValue: provider.signKeyInfo?.storepass,
      onSaved: (v) => provider.updateSignKeyInfo(storepass: v),
      decoration: InputDecoration(
        labelText: label,
        hintText: '请输入$label',
        suffixIcon: IconButton(
          icon: Icon(samePass ? Icons.link_rounded : Icons.link_off_rounded),
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

  // 构建可选表单项（折叠）
  Widget _buildOptionFields(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('其他可选参数'),
      children: [
        Row(children: [
          Expanded(child: _buildKeyAlgField(context)),
          Expanded(child: _buildKeySizeField(context)),
          Expanded(child: _buildValidityField(context)),
        ]),
        Row(children: [
          Expanded(
              child: _buildDNameField(context,
                  label: '组织',
                  initialValue: provider.signKeyInfo?.dNameO,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameO: v))),
          Expanded(
              child: _buildDNameField(context,
                  label: '组织单位',
                  initialValue: provider.signKeyInfo?.dNameOU,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameOU: v))),
        ]),
        Row(children: [
          Expanded(
              child: _buildDNameField(context,
                  label: '持有者',
                  initialValue: provider.signKeyInfo?.dNameCN,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameCN: v))),
          Expanded(
              child: _buildDNameField(context,
                  label: '职位/头衔',
                  initialValue: provider.signKeyInfo?.dNameT,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameT: v))),
        ]),
        Row(children: [
          Expanded(
              child: _buildDNameField(context,
                  label: '国家/地区',
                  initialValue: provider.signKeyInfo?.dNameC,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameC: v))),
          Expanded(
              child: _buildDNameField(context,
                  label: '城市或区域',
                  initialValue: provider.signKeyInfo?.dNameL,
                  onSaved: (v) => provider.updateSignKeyInfo(dNameL: v))),
        ]),
      ],
    );
  }

  // 构建签名alg
  Widget _buildKeyAlgField(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return Selector<AndroidSignKeyDialogProvider, String?>(
      selector: (_, provider) => provider.signKeyInfo?.keyAlg,
      builder: (_, keyAlg, __) {
        return DropdownButtonFormField<String>(
          value: keyAlg,
          decoration: const InputDecoration(
            labelText: '加密',
            hintText: '请选择加密',
          ),
          items: const [
            DropdownMenuItem(
              value: 'RSA',
              child: Text('RSA'),
            ),
            DropdownMenuItem(
              value: 'DSA',
              child: Text('DSA'),
            ),
          ],
          onChanged: (v) => provider.updateSignKeyInfo(keyAlg: v),
        );
      },
    );
  }

  // 构建签名长度
  Widget _buildKeySizeField(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return Selector<AndroidSignKeyDialogProvider, int?>(
      selector: (_, provider) => provider.signKeyInfo?.keySize,
      builder: (_, keySize, __) {
        return DropdownButtonFormField<int>(
          value: keySize,
          decoration: const InputDecoration(
            labelText: '长度',
            hintText: '请选择长度',
          ),
          items: const [
            DropdownMenuItem(
              value: 2048,
              child: Text('2048'),
            ),
          ],
          onChanged: (v) => provider.updateSignKeyInfo(keySize: v),
        );
      },
    );
  }

  // 构建签名有效期
  Widget _buildValidityField(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    return Selector<AndroidSignKeyDialogProvider, int?>(
      selector: (_, provider) => provider.signKeyInfo?.validity,
      builder: (_, validity, __) {
        validity ??= 99 * 365;
        return DropdownButtonFormField<int>(
          value: validity ~/ 365,
          decoration: const InputDecoration(
            labelText: '有效期',
            hintText: '请选择有效期',
          ),
          items: List.generate(
              99, (i) => DropdownMenuItem(value: ++i, child: Text('$i年'))),
          onChanged: (v) {
            if (v == null) return;
            provider.updateSignKeyInfo(validity: v * 365);
          },
        );
      },
    );
  }

  // 其他dName字段
  Widget _buildDNameField(
    BuildContext context, {
    required String label,
    String? initialValue,
    FormFieldSetter<String>? onSaved,
  }) {
    return TextFormField(
      onSaved: onSaved,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: '请输入$label',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
      ],
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

  // 是否使用同一个密码
  bool _samePass = true;

  // 判断是否使用同一个密码
  bool get samePass => _samePass;

  // 表单数据
  AndroidSignKeyFormTuple? _signKeyInfo;

  // 表单数据
  AndroidSignKeyFormTuple? get signKeyInfo => _signKeyInfo;

  // keytool路径输入控制器
  final keytoolPathController = TextEditingController();

  AndroidSignKeyDialogProvider(super.context) {
    updateSignKeyInfo();
    _updateKeytoolPath();
  }

  // 更新keytool路径
  Future<void> _updateKeytoolPath() async {
    final path = await ProjectTool.getJavaKeyToolPath();
    if (path == null) return;
    keytoolPathController.text = path;
    updateSignKeyInfo(keytool: path);
  }

  // 提交表单
  Future<bool> submitForm() async {
    /// 实现表单校验
    return true;
  }

  // 更新是否使用同一个密码
  void toggleSamePass() {
    _samePass = !samePass;
    notifyListeners();
  }

  // 更新表单数据(copyWith)
  void updateSignKeyInfo({
    String? keytool,
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
      keytool: keytool ?? _signKeyInfo?.keytool ?? '',
      path: path ?? _signKeyInfo?.path ?? '',
      alias: alias ?? _signKeyInfo?.alias ?? '',
      storepass: storepass ?? _signKeyInfo?.storepass ?? '',
      keypass: keypass ?? _signKeyInfo?.keypass ?? '',
      keyAlg: keyAlg ?? _signKeyInfo?.keyAlg ?? 'RSA',
      keySize: keySize ?? _signKeyInfo?.keySize ?? 2048,
      validity: validity ?? _signKeyInfo?.validity ?? 99 * 365,
      dNameCN: dNameCN ?? _signKeyInfo?.dNameCN ?? '-',
      dNameOU: dNameOU ?? _signKeyInfo?.dNameOU ?? '-',
      dNameO: dNameO ?? _signKeyInfo?.dNameO ?? '-',
      dNameL: dNameL ?? _signKeyInfo?.dNameL ?? '-',
      dNameT: dNameT ?? _signKeyInfo?.dNameT ?? '-',
      dNameC: dNameC ?? _signKeyInfo?.dNameC ?? '-',
    );
    notifyListeners();
  }
}
