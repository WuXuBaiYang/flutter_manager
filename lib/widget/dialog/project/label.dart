import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:jtech_base/jtech_base.dart';

// 展示修改别名弹窗
Future<Map<PlatformType, String>?> showProjectLabel(BuildContext context,
    {required Map<PlatformType, String> platformLabelMap}) async {
  return showDialog<Map<PlatformType, String>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProjectLabelDialog(
      platformLabelMap: platformLabelMap,
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
  final Map<PlatformType, String> platformLabelMap;

  ProjectLabelDialog({super.key, required this.platformLabelMap});

  @override
  ProjectLabelDialogProvider createProvider(BuildContext context) =>
      ProjectLabelDialogProvider(context, platformLabelMap);

  @override
  Widget buildWidget(BuildContext context) {
    final provider = context.watch<ProjectLabelDialogProvider>();
    return CustomDialog(
      title: const Text('别名'),
      content: _buildContent(context),
      constraints: BoxConstraints.tightFor(
          width: 280, height: platformLabelMap.isEmpty ? 280 : null),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () async {
            final result = await provider.submitForm();
            if (result == null || !context.mounted) return;
            Navigator.pop(context, result);
          },
        ),
      ],
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    final provider = context.read<ProjectLabelDialogProvider>();
    return EmptyBoxView(
      hint: '无可用平台',
      isEmpty: platformLabelMap.isEmpty,
      child: Form(
        key: provider.formKey,
        child: Selector<ProjectLabelDialogProvider, List<PlatformType>>(
          selector: (_, provider) => provider.linkPlatformList,
          builder: (_, linkList, __) {
            final result = provider.groupByLinkPlatform(platformLabelMap);
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormFieldLinkList(context, result.linkMap),
                  _buildFormFieldLabels(context, result.labelMap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 构建联动平台列表
  Widget _buildFormFieldLinkList(
      BuildContext context, Map<PlatformType, String> platformLabelMap) {
    final provider = context.read<ProjectLabelDialogProvider>();
    if (platformLabelMap.isEmpty) return const SizedBox();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: provider.updateLinkPlatformField,
              decoration: const InputDecoration(
                labelText: '别名',
                hintText: '输入全平台统一别名',
              ),
            ),
            ...List.generate(platformLabelMap.length, (i) {
              final item = platformLabelMap.entries.elementAt(i);
              return _buildFormFieldLabelItem(context, item, true);
            }),
          ],
        ),
      ),
    );
  }

  // 构建平台与label表单项
  Widget _buildFormFieldLabels(
      BuildContext context, Map<PlatformType, String> platformLabelMap) {
    return Column(
      children: List.generate(platformLabelMap.length, (i) {
        final item = platformLabelMap.entries.elementAt(i);
        return _buildFormFieldLabelItem(context, item, false);
      }),
    );
  }

  // 构建label表单项
  Widget _buildFormFieldLabelItem(
      BuildContext context, MapEntry<PlatformType, String> item,
      [bool linked = true]) {
    final provider = context.read<ProjectLabelDialogProvider>();
    final textStyle = linked ? const TextStyle(color: Colors.grey) : null;
    return TextFormField(
      readOnly: linked,
      style: textStyle,
      initialValue: item.value,
      key: provider.getPlatformFieldKey(item.key),
      validator: provider.getPlatformValidator(item.key),
      onSaved: (v) => provider.updateLabel(item.key, v),
      decoration: InputDecoration(
          labelStyle: textStyle,
          labelText: item.key.name,
          suffix: IconButton(
            iconSize: 18,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => provider.updateLinkPlatform(item.key),
            icon: Icon(
              linked ? Icons.link : Icons.link_off_rounded,
              color: linked ? Colors.grey : null,
            ),
          )),
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

  // 平台label对照表
  Map<PlatformType, String> _formData = {};

  // 获取平台label对照表
  Map<PlatformType, String> get formData => _formData;

  // 记录所选联动平台列表
  List<PlatformType> _linkPlatformList = [];

  // 获取所选联动平台列表
  List<PlatformType> get linkPlatformList => _linkPlatformList;

  // 维护平台表单项key
  final _platformFieldKeyMap =
      <PlatformType, GlobalKey<FormFieldState<String>>>{};

  // 平台label校验对照表
  late final _platformValidatorMap =
      <PlatformType, FormFieldValidator<String>?>{
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

  ProjectLabelDialogProvider(
      super.context, Map<PlatformType, String> platformLabels) {
    _linkPlatformList = platformLabels.keys.toList();
    _formData = platformLabels;
  }

  // 提交表单数据
  Future<Map<PlatformType, String>?> submitForm() async {
    try {
      final formState = formKey.currentState;
      if (!(formState?.validate() ?? false)) return null;
      formState!.save();
      return _formData;
    } catch (e) {
      Notice.showError(context, message: e.toString(), title: '操作失败');
    }
    return null;
  }

  // 根据平台校验label
  FormFieldValidator<String> getPlatformValidator(PlatformType platform) {
    return _platformValidatorMap[platform] ??
        (v) {
          if (v?.isEmpty ?? true) {
            return '请输入别名';
          }
          return null;
        };
  }

  // 获取平台对应的表单项key
  GlobalKey<FormFieldState<String>> getPlatformFieldKey(PlatformType platform) {
    return _platformFieldKeyMap[platform] ??=
        GlobalKey<FormFieldState<String>>();
  }

  // 更新所有链接平台的字段
  void updateLinkPlatformField(String label) {
    for (var platform in _linkPlatformList) {
      getPlatformFieldKey(platform).currentState?.didChange(label);
    }
  }

  // 根据平台更新label
  void updateLabel(PlatformType platform, String? label) {
    if (label?.isEmpty ?? true) return;
    _formData[platform] = label!;
    notifyListeners();
  }

  // 更新所选联动平台列表
  void updateLinkPlatform(PlatformType platform) {
    _linkPlatformList = [
      if (_linkPlatformList.contains(platform))
        ..._linkPlatformList.where((e) => e != platform)
      else ...[..._linkPlatformList, platform]
    ];
    notifyListeners();
  }

  // 将平台label对照表拆分为两组
  ({Map<PlatformType, String> linkMap, Map<PlatformType, String> labelMap})
      groupByLinkPlatform(Map<PlatformType, String> platformLabelMap) {
    final result =
        (linkMap: <PlatformType, String>{}, labelMap: <PlatformType, String>{});
    platformLabelMap.forEach((k, v) {
      linkPlatformList.contains(k)
          ? result.linkMap[k] = v
          : result.labelMap[k] = v;
    });
    return result;
  }
}
