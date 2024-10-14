import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/database/model/project.dart';
import 'package:flutter_manager/widget/dialog/project_asset.dart';
import 'package:flutter_manager/widget/dialog/project_build.dart';
import 'package:flutter_manager/widget/dialog/project_font.dart';
import 'package:flutter_manager/widget/env_badge.dart';
import 'package:flutter_manager/widget/app_bar.dart';
import 'package:open_dir/open_dir.dart';

/*
* 项目详情页appBar
* @author wuxubaiyang
* @Time 2023/12/13 15:54
*/
class ProjectDetailAppBar extends StatelessWidget {
  // 项目信息
  final Project project;

  // 折叠头部高度
  final double expandedHeight;

  // 底部组件
  final PreferredSizeWidget? bottom;

  // 是否为展开模式
  final bool isCollapsed;

  // 项目编辑回调
  final VoidCallback? onProjectEdit;

  const ProjectDetailAppBar({
    super.key,
    required this.project,
    this.expandedHeight = 165.0,
    this.isCollapsed = false,
    this.onProjectEdit,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final color = project.color;
    final hasColor = color != Colors.transparent;
    return SliverAppBar(
      pinned: true,
      bottom: bottom,
      titleSpacing: 6,
      expandedHeight: expandedHeight,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: hasColor ? 8 : 1,
      surfaceTintColor: hasColor ? color : null,
      title: CustomAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          const BackButton(),
          _buildCollapsedTitle(context),
          const Spacer(),
        ],
      ),
      flexibleSpace: _buildFlexibleSpace(
          context, hasColor ? color.withOpacity(0.2) : null),
    );
  }

  // 构建收缩后的标题
  Widget _buildCollapsedTitle(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    return AnimatedOpacity(
      opacity: isCollapsed ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: Image.file(File(project.logo),
                fit: BoxFit.cover, width: 30, height: 30),
          ),
          const SizedBox(width: 14),
          Text(project.label),
          const SizedBox(width: 8),
          _buildEnvironmentBadge(),
        ],
      ),
    );
  }

  // 构建FlexibleSpace
  Widget _buildFlexibleSpace(BuildContext context, Color? color) {
    return FlexibleSpaceBar(
      background: Card(
        child: Container(
          color: color,
          child: Row(children: [
            Expanded(child: _buildProjectInfo(context)),
            _buildActions(context),
          ]),
        ),
      ),
    );
  }

  // 构建项目信息
  Widget _buildProjectInfo(BuildContext context) {
    var bodyStyle = Theme.of(context).textTheme.bodySmall;
    final color = bodyStyle?.color?.withOpacity(0.4);
    bodyStyle = bodyStyle?.copyWith(color: color);
    return ListTile(
      isThreeLine: true,
      title: Row(children: [
        ConstrainedBox(
          constraints: BoxConstraints.loose(const Size.fromWidth(220)),
          child:
              Text(project.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        _buildEnvironmentBadge(),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 14,
          onPressed: onProjectEdit,
          icon: const Icon(Icons.edit),
          visualDensity: VisualDensity.compact,
        ),
      ]),
      leading: Image.file(File(project.logo), width: 55, height: 55),
      subtitle: Text(project.path,
          maxLines: 1, style: bodyStyle, overflow: TextOverflow.ellipsis),
    );
  }

  // 构建操作按钮
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          iconSize: 20,
          tooltip: 'Asset管理',
          icon: const Icon(Icons.assessment_outlined),
          onPressed: () => showProjectAsset(context),
        ),
        IconButton.outlined(
          iconSize: 20,
          tooltip: '字体管理',
          icon: const Icon(Icons.font_download_outlined),
          onPressed: () => showProjectFont(context),
        ),
        IconButton.outlined(
          iconSize: 20,
          tooltip: '打开项目目录',
          icon: const Icon(Icons.file_open_outlined),
          onPressed: () => OpenDir().openNativeDir(path: project.path),
        ),
        FilledButton.icon(
          label: const Text('打包'),
          icon: const Icon(Icons.build),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(const Size.fromHeight(55)),
            shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            textStyle:
                WidgetStatePropertyAll(Theme.of(context).textTheme.bodyLarge),
          ),
          onPressed: () => showProjectBuild(context, project: project),
        ),
      ].expand((e) => [e, const SizedBox(width: 14)]).toList(),
    );
  }

  // 构建项目环境标签
  Widget _buildEnvironmentBadge() {
    final result = database.getEnvironmentById(project.envId);
    if (result == null) return const SizedBox();
    return EnvBadge(env: result);
  }
}
