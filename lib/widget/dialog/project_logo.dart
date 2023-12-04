import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project_logo.dart';
import 'package:flutter_manager/widget/custom_dialog.dart';
import 'package:provider/provider.dart';

/*
* 项目修改图标弹窗
* @author wuxubaiyang
* @Time 2023/12/1 9:17
*/
class ProjectLogoDialog extends StatelessWidget {
  // 平台与图标表
  final Map<PlatformType, List<PlatformLogoTuple>> platformLogoMap;

  const ProjectLogoDialog({super.key, required this.platformLogoMap});

  // 展示弹窗
  static Future<Map<PlatformType, String>?> show(BuildContext context,
      {required Map<PlatformType, List<PlatformLogoTuple>>
          platformLogoMap}) async {
    return showDialog<Map<PlatformType, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectLogoDialog(
        platformLogoMap: platformLogoMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectLogoDialogProvider(
        platformLogoMap.keys.toList(),
      ),
      builder: (context, _) {
        return CustomDialog(
          title: const Text('图标'),
          content: _buildContent(context),
          constraints: const BoxConstraints.tightForFinite(width: 450),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Selector<ProjectLogoDialogProvider,
          ({PlatformType? expanded, List<PlatformType> checkedList})>(
        selector: (_, provider) => (
          expanded: provider.expandedPlatform,
          checkedList: provider.checkedPlatforms,
        ),
        builder: (_, result, __) {
          return ExpansionPanelList.radio(
            materialGapSize: 8,
            initialOpenPanelValue: result.expanded,
            expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
            expansionCallback: (index, isExpanded) => context
                .read<ProjectLogoDialogProvider>()
                .updateExpandedPlatform(
                  isExpanded ? null : platformLogoMap.keys.elementAt(index),
                ),
            children: List.generate(platformLogoMap.length, (i) {
              final item = platformLogoMap.entries.elementAt(i);
              return _buildExpansionPanelItem(
                  context, item, result.checkedList.contains(item.key));
            }),
          );
        },
      ),
    );
  }

  // 构建展开项
  ExpansionPanelRadio _buildExpansionPanelItem(BuildContext context,
      MapEntry<PlatformType, List<PlatformLogoTuple>> item, bool isChecked) {
    final provider = context.read<ProjectLogoDialogProvider>();
    return ExpansionPanelRadio(
      value: item.key,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Tooltip(
            message: '替换该平台',
            child: Checkbox(
              value: isChecked,
              onChanged: (_) {
                provider.updateCheckedPlatform(item.key);
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
}

/*
* 项目修改图标弹窗数据提供者
* @author wuxubaiyang
* @Time 2023/12/4 15:26
*/
class ProjectLogoDialogProvider extends BaseProvider {
  // 当前展开平台
  PlatformType? _expandedPlatform;

  // 当前展开平台
  PlatformType? get expandedPlatform => _expandedPlatform;

  // 记录已选平台
  List<PlatformType> _checkedPlatforms = [];

  // 获取已选平台
  List<PlatformType> get checkedPlatforms => _checkedPlatforms;

  ProjectLogoDialogProvider(List<PlatformType> platforms) {
    _checkedPlatforms = platforms;
  }

  // 更新展开平台
  void updateExpandedPlatform(PlatformType? platform) {
    _expandedPlatform = platform;
    notifyListeners();
  }

  // 更新所选平台
  void updateCheckedPlatform(PlatformType platform) {
    _checkedPlatforms = [
      ..._checkedPlatforms.contains(platform)
          ? (_checkedPlatforms..remove(platform))
          : (_checkedPlatforms..add(platform))
    ];
    notifyListeners();
  }
}
