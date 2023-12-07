import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/*
* 项目平台信息项组件
* @author wuxubaiyang
* @Time 2023/12/1 17:30
*/
class ProjectPlatformItem extends StatelessWidget {
  // 主轴方向的单元格数量
  final int crossAxisCellCount;

  // 交叉轴方向的单元格数量
  final num? mainAxisCellCount;

  // 主轴方向的单元格大小
  final double? mainAxisExtent;

  // 子元素
  final Widget content;

  // 点击事件
  final GestureTapCallback? onTap;

  // 标题
  final String? title;

  // 表单key
  final GlobalKey<FormState> formKey;

  // 表单提交回调
  final VoidCallback? onSubmitted;

  // 控制器
  final ProjectPlatformItemController? controller;

  ProjectPlatformItem.count({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisCellCount,
    required this.content,
    this.title,
    this.onTap,
    this.controller,
    this.onSubmitted,
  })  : mainAxisExtent = null,
        formKey = GlobalKey<FormState>();

  ProjectPlatformItem.extent({
    super.key,
    required this.crossAxisCellCount,
    required this.mainAxisExtent,
    required this.content,
    this.title,
    this.onTap,
    this.controller,
    this.onSubmitted,
  })  : mainAxisCellCount = null,
        formKey = GlobalKey<FormState>();

  ProjectPlatformItem.fit({
    super.key,
    required this.crossAxisCellCount,
    required this.content,
    this.title,
    this.onTap,
    this.controller,
    this.onSubmitted,
  })  : mainAxisCellCount = null,
        mainAxisExtent = null,
        formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (mainAxisCellCount != null) {
      return StaggeredGridTile.count(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisCellCount: mainAxisCellCount!,
        child: _buildPlatformItem(context),
      );
    }
    if (mainAxisExtent != null) {
      return StaggeredGridTile.extent(
        crossAxisCellCount: crossAxisCellCount,
        mainAxisExtent: mainAxisExtent!,
        child: _buildPlatformItem(context),
      );
    }
    return StaggeredGridTile.fit(
      crossAxisCellCount: crossAxisCellCount,
      child: _buildPlatformItem(context),
    );
  }

  // 构建平台信息项
  Widget _buildPlatformItem(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 8, horizontal: 14);
    return Form(
      key: formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title?.isNotEmpty ?? false)
                    Text(title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(child: content),
                  _buildPlatformItemActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建平台信息项操作
  Widget _buildPlatformItemActions(BuildContext context) {
    if (controller == null || onSubmitted == null) return const SizedBox();
    return ValueListenableBuilder<bool>(
      valueListenable: controller!,
      builder: (_, isEdited, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: !isEdited ? null : _submitForm,
              child: const Text('修改'),
            ),
          ],
        );
      },
    );
  }

  // 修改变动并反馈回调
  void _submitForm() {
    if (onSubmitted == null) return;
    final formState = formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;
    formState.save();
    onSubmitted?.call();
  }
}

/*
* 项目平台信息项控制器
* @author wuxubaiyang
* @Time 2023/12/1 17:30
*/
class ProjectPlatformItemController extends ValueNotifier<bool> {
  ProjectPlatformItemController() : super(false);

  void edit([bool edited = true]) => value = edited;
}
