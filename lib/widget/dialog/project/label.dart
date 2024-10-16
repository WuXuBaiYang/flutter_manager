import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示修改别名弹窗
Future<Map<PlatformType, String>?> showProjectLabel(BuildContext context,
    {required Map<PlatformType, String> labelMap}) async {
  return showDialog<Map<PlatformType, String>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectLabelDialog(
      labelMap: labelMap,
    ),
  );
}

/*
* 项目修改别名弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLabelDialog extends ProviderView<ProjectLabelDialogProvider> {
  // 平台与label对照表
  final Map<PlatformType, String> labelMap;

  ProjectLabelDialog({super.key, required this.labelMap});

  @override
  ProjectLabelDialogProvider createProvider(BuildContext context) =>
      ProjectLabelDialogProvider(context, labelMap);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: const Text('别名'),
      content: _buildContent(context),
      constraints: BoxConstraints(
        maxHeight: min(labelMap.length * 100, 380),
        maxWidth: 380,
      ),
      actions: [
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
    return EmptyBoxView(
      hint: '无可用平台',
      isEmpty: labelMap.isEmpty,
      child: Form(
        key: provider.formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            _buildLinkLabels(context),
            _buildLabels(context),
          ]),
        ),
      ),
    );
  }

  // 构建联动平台列表
  Widget _buildLinkLabels(BuildContext context) {
    return Selector<ProjectLabelDialogProvider, Map<PlatformType, String?>>(
      selector: (_, provider) => provider.linkLabelMap,
      builder: (_, linkLabelMap, __) {
        if (linkLabelMap.isEmpty) return const SizedBox();
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              TextField(
                autofocus: true,
                onChanged: provider.updateLinkField,
                decoration: const InputDecoration(
                  labelText: '别名',
                  hintText: '输入全平台统一别名',
                ),
              ),
              ...List.generate(linkLabelMap.length, (i) {
                final item = linkLabelMap.entries.elementAt(i);
                return _buildLabelItem(context, item, true);
              }),
            ]),
          ),
        );
      },
    );
  }

  // 构建平台与label表单项
  Widget _buildLabels(BuildContext context) {
    return Selector<ProjectLabelDialogProvider, Map<PlatformType, String?>>(
      selector: (_, provider) => provider.labelMap,
      builder: (_, labelMap, __) {
        return Column(
          children: List.generate(labelMap.length, (i) {
            final item = labelMap.entries.elementAt(i);
            return _buildLabelItem(context, item, false);
          }),
        );
      },
    );
  }

  // 构建label表单项
  Widget _buildLabelItem(
      BuildContext context, MapEntry<PlatformType, String?> item,
      [bool linked = true]) {
    final textStyle = linked ? const TextStyle(color: Colors.grey) : null;
    final decoration = InputDecoration(
      labelStyle: textStyle,
      labelText: item.key.name,
      suffix: IconButton(
        iconSize: 18,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: () => provider.updateLink(item.key),
        icon: Icon(
          linked ? Icons.link : Icons.link_off_rounded,
          color: linked ? Colors.grey : null,
        ),
      ),
    );
    return TextFormField(
      readOnly: linked,
      style: textStyle,
      decoration: decoration,
      initialValue: item.value,
      key: provider.fieldKey(item.key),
      validator: provider.validator(item.key),
      onSaved: (v) => provider.updateLabel(item.key, v),
    );
  }
}

/*
* 项目修改别名弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/5 14:51
*/
class ProjectLabelDialogProvider extends BaseProvider {
  // 表单key
  final formKey = GlobalKey<FormState>();

  // 维护平台表单项key
  final _fieldKeyMap = <PlatformType, GlobalKey<FormFieldState<String>>>{};

  // 平台label校验对照表
  late final _validatorMap = <PlatformType, FormFieldValidator<String>?>{
    PlatformType.android: null,
    PlatformType.ios: null,
    PlatformType.web: null,
    PlatformType.windows: (v) {
      if (v?.isEmpty ?? true) {
        return '请输入别名';
      }
      // 仅支持英文大小写与数字下划线正则
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v!)) {
        return '仅支持英文大小写与数字下划线';
      }
      return null;
    },
    PlatformType.macos: null,
    PlatformType.linux: null,
  };

  ProjectLabelDialogProvider(super.context, this._formData)
      : _linkList = _formData.keys.toList();

  // 平台label对照表
  Map<PlatformType, String> _formData;

  // 获取平台label对照表
  Map<PlatformType, String> get formData => _formData;

  // 记录所选联动平台列表
  List<PlatformType> _linkList;

  // 获取所选联动平台列表
  List<PlatformType> get linkList => _linkList;

  // 获取联动平台label表
  Map<PlatformType, String?> get linkLabelMap =>
      _linkList.asMap().map((_, v) => MapEntry(v, _formData[v]));

  // 获取非联动平台label表
  Map<PlatformType, String?> get labelMap => Map.fromEntries(
      _formData.entries.where((e) => !_linkList.contains(e.key)));

  // 提交表单数据
  Future<Map<PlatformType, String>?> submit() async {
    try {
      final formState = formKey.currentState;
      if (formState == null || !formState.validate()) return null;
      formState.save();
      context.pop(_formData);
      return _formData;
    } catch (e) {
      showNoticeError(e.toString(), title: '操作失败');
    }
    return null;
  }

  // 根据平台校验label
  FormFieldValidator<String> validator(PlatformType platform) =>
      _validatorMap[platform] ??
      (v) {
        if (v?.isNotEmpty != true) return '请输入别名';
        return null;
      };

  // 获取平台对应的表单项key
  GlobalKey<FormFieldState<String>> fieldKey(PlatformType platform) =>
      _fieldKeyMap[platform] ??= GlobalKey<FormFieldState<String>>();

  // 更新所有链接平台的字段
  void updateLinkField(String label) {
    for (var e in _linkList) {
      fieldKey(e).currentState?.didChange(label);
    }
  }

  // 根据平台更新label
  void updateLabel(PlatformType platform, String? label) {
    if (label == null || label.isEmpty) return;
    _formData = _formData..[platform] = label;
    notifyListeners();
  }

  // 更新所选联动平台列表
  void updateLink(PlatformType platform) {
    _linkList = [
      if (!_linkList.remove(platform))
        ..._linkList..add(platform)
      else
        ..._linkList
    ];
    notifyListeners();
  }
}
