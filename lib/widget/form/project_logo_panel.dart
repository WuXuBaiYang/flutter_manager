import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';

// 项目图标折叠展示表单项值元组
typedef LogoPanelFieldTuple = ({
  PlatformType? expanded,
  List<PlatformType> platforms,
});

/*
* 项目图标折叠展示表单项组件
* @author wuxubaiyang
* @Time 2023/12/4 19:50
*/
class ProjectLogoPanelFormField extends StatelessWidget {
  // 初始化值
  final LogoPanelFieldTuple? initialValue;

  // 保存回调
  final FormFieldSetter<LogoPanelFieldTuple>? onSaved;

  // 平台与图标表
  final Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap;

  const ProjectLogoPanelFormField({
    super.key,
    required this.platformLogoMap,
    this.onSaved,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<LogoPanelFieldTuple>(
      initialValue: initialValue,
      validator: (v) {
        if (v?.platforms.isEmpty ?? true) {
          return '请选择平台';
        }
        return null;
      },
      onSaved: onSaved,
      builder: (field) {
        return _buildFormField(context, field);
      },
    );
  }

  // 构建表单字段
  Widget _buildFormField(
      BuildContext context, FormFieldState<LogoPanelFieldTuple> field) {
    final inputDecoration = InputDecoration(
      border: InputBorder.none,
      errorText: field.errorText,
    );
    return InputDecorator(
      decoration: inputDecoration,
      child: ExpansionPanelList.radio(
        elevation: 0,
        materialGapSize: 8,
        initialOpenPanelValue: field.value?.expanded,
        expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
        expansionCallback: (index, isExpanded) {
          _onExpansionPanelChanged(index, isExpanded, field);
        },
        children: List.generate(platformLogoMap.length, (i) {
          final item = platformLogoMap.entries.elementAt(i);
          return _buildExpansionPanelItem(context, item, field);
        }),
      ),
    );
  }

  // 构建展开项
  ExpansionPanelRadio _buildExpansionPanelItem(
      BuildContext context,
      MapEntry<PlatformType, List<PlatformLogoTuple>> item,
      FormFieldState<LogoPanelFieldTuple> field) {
    final checked = field.value?.platforms.contains(item.key) ?? false;
    return ExpansionPanelRadio(
      value: item.key,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Tooltip(
            message: '替换该平台',
            child: Checkbox(
              value: checked,
              isError: field.hasError,
              onChanged: (v) {
                _onCheckboxChanged(v == true, field, item.key);
              },
            ),
          ),
          title: Text(item.key.name),
          trailing: Tooltip(
            message: '图标数量',
            child: Text('${item.value.length}'),
          ),
        );
      },
      body: ProjectLogoGrid(
        logoList: item.value,
      ),
    );
  }

  // 展开项事件
  void _onExpansionPanelChanged(
      int index, bool isExpanded, FormFieldState<LogoPanelFieldTuple> field) {
    field.didChange((
      expanded: isExpanded ? platformLogoMap.keys.elementAt(index) : null,
      platforms: field.value?.platforms ?? []
    ));
  }

  // 多选框事件
  void _onCheckboxChanged(bool checked,
      FormFieldState<LogoPanelFieldTuple> field, PlatformType platform) {
    final temp = field.value?.platforms ?? [];
    checked ? temp.add(platform) : temp.remove(platform);
    field.didChange((
      expanded: field.value?.expanded,
      platforms: temp,
    ));
  }
}
