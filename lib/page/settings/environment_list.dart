import 'package:flutter/material.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/provider/environment.dart';
import 'package:flutter_manager/tool/loading.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/snack.dart';
import 'package:flutter_manager/widget/dialog/environment.dart';
import 'package:provider/provider.dart';

/*
* 环境列表
* @author wuxubaiyang
* @Time 2023/11/27 10:03
*/
class EnvironmentList extends StatelessWidget {
  // 约束
  final BoxConstraints constraints;

  const EnvironmentList({
    super.key,
    this.constraints = const BoxConstraints(maxHeight: 240),
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Selector<EnvironmentProvider, List<Environment>>(
          selector: (_, provider) => provider.environments,
          builder: (_, environments, __) {
            if (environments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: Text('暂无环境'),
              );
            }
            return ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: environments.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, __, ___) => Card(
                margin: EdgeInsets.zero,
                child: child,
              ),
              onReorder: (oldIndex, newIndex) => context
                  .read<EnvironmentProvider>()
                  .reorder(environments[oldIndex], newIndex),
              itemBuilder: (_, index) {
                final item = environments[index];
                return _buildFlutterEnvironmentListItem(context, item);
              },
            );
          },
        ),
      ),
    );
  }

  // 构建Flutter环境列表项
  Widget _buildFlutterEnvironmentListItem(
      BuildContext context, Environment item) {
    final pathAvailable = EnvironmentTool.isPathAvailable(item.path);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeEnvironment(context, item),
      confirmDismiss: (_) => _confirmDismiss(context, item),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 14),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.path),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!pathAvailable) ...[
              const Tooltip(
                message: '环境不存在',
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
            ],
            IconButton(
              iconSize: 18,
              tooltip: '编辑环境',
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  EnvironmentImportDialog.show(context, environment: item),
            ),
            IconButton(
              iconSize: 18,
              tooltip: '刷新环境',
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshEnvironment(context, item),
            ),
            const SizedBox(width: 8),
            ReorderableDragStartListener(
              index: item.order,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
      ),
    );
  }

  // 移除环境
  void _removeEnvironment(BuildContext context, Environment item) {
    final provider = context.read<EnvironmentProvider>()..remove(item);
    SnackTool.showMessage(
      context,
      message: '${item.title} 环境已移除',
      action: SnackBarAction(
        label: '撤销',
        onPressed: () => provider.update(item),
      ),
    );
  }

  // 环境移除确认
  Future<bool> _confirmDismiss(BuildContext context, Environment item) =>
      context.read<EnvironmentProvider>().removeValidator(item).then(
        (result) {
          final canRemove = result == null;
          if (!canRemove) SnackTool.showMessage(context, message: result);
          return canRemove;
        },
      );

  // 刷新环境
  void _refreshEnvironment(BuildContext context, Environment item) {
    final provider = context.read<EnvironmentProvider>();
    Loading.show(
      context,
      loadFuture: provider.update(item),
    )?.then((_) {}).catchError((e) {
      SnackTool.showMessage(context, message: '刷新失败：$e');
      provider.update(item);
    });
  }
}
