import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_manager/tool/project/platform/android.dart';
import 'package:provider/provider.dart';
import 'android_sign_key.dart';

// dName可选项表单元组
typedef AndroidSignDNameTuple = ({
  String label,
  String? Function(AndroidSignKeyFormTuple? signKeyInfo) initialValue,
  void Function(AndroidSignKeyDialogProvider provider, String? v) onSaved,
});

/*
* Android签名生成工具表单组件
* @author wuxubaiyang
* @Time 2023/12/28 8:26
*/
class AndroidSignKeyOptions extends StatelessWidget {
  AndroidSignKeyOptions({super.key});

  // 可选项DName表
  final List<List<AndroidSignDNameTuple>> _dNameOptions = [
    [
      (
        label: '组织',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameO,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameO: v),
      ),
      (
        label: '组织单位',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameOU,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameOU: v),
      ),
    ],
    [
      (
        label: '持有者',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameCN,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameCN: v),
      ),
      (
        label: '职位/头衔',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameT,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameT: v),
      ),
    ],
    [
      (
        label: '国家/地区',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameC,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameC: v),
      ),
      (
        label: '城市或区域',
        initialValue: (signKeyInfo) => signKeyInfo?.dNameL,
        onSaved: (provider, v) => provider.updateSignKeyInfo(dNameL: v),
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AndroidSignKeyDialogProvider>();
    final signKeyInfo = provider.signKeyInfo;
    return Column(children: [
      Row(children: [
        Expanded(child: _buildKeyAlgField(context)),
        Expanded(child: _buildKeySizeField(context)),
        Expanded(child: _buildValidityField(context)),
      ]),
      ..._dNameOptions.map((e) {
        return Row(
          children: e.map((e) {
            return Expanded(
              child: _buildDNameField(
                context,
                label: e.label,
                onSaved: (v) => e.onSaved(provider, v),
                initialValue: e.initialValue(signKeyInfo),
              ),
            );
          }).toList(),
        );
      }),
    ]);
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
