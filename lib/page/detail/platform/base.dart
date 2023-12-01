import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:flutter_manager/tool/project/project.dart';
import 'package:provider/provider.dart';

/*
* 项目平台信息页面基类
* @author wuxubaiyang
* @Time 2023/12/1 9:41
*/
abstract class ProjectPlatformPage extends BasePage {
  const ProjectPlatformPage({
    super.key,
    super.primary = false,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return SizedBox();
  }
}

/*
* 项目平台信息provider
* @author wuxubaiyang
* @Time 2023/11/30 18:48
*/
abstract class ProjectPlatformProvider extends BaseProvider {
  // 平台类型
  final PlatformPath platform;

  // 缓存是否存在平台信息
  bool _hasPlatform = false;

  // 是否存在平台信息
  bool get hasPlatform => _hasPlatform;

  ProjectPlatformProvider(BuildContext context, this.platform) {
    final project = getProjectInfo(context);
    if (project == null) return;
    // 初始化是否存在平台信息
    _hasPlatform = ProjectTool.hasPlatform(platform, project.path);
  }

  // 创建平台信息
  Future<bool> createPlatform(BuildContext context) async {
    final project = getProjectInfo(context);
    if (project == null) return false;
    _hasPlatform = await ProjectTool.createPlatform(project, platform);
    notifyListeners();
    return _hasPlatform;
  }

  // 获取项目信息
  Project? getProjectInfo(BuildContext context) =>
      context.read<ProjectDetailPageProvider>().project;
}
