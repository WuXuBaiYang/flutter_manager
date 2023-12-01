import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/page/detail/index.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';
import 'package:provider/provider.dart';

/*
* 项目平台信息页面基类
* @author wuxubaiyang
* @Time 2023/12/1 9:41
*/
abstract class ProjectPlatformPage extends BasePage {
  // 平台类型
  final PlatformPath platformPath;

  const ProjectPlatformPage({
    super.key,
    super.primary = false,
    required this.platformPath,
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
abstract class ProjectPlatformProvider extends ChangeNotifier {
  // 获取项目信息
  Project? getProjectInfo(BuildContext context) =>
      context.read<ProjectDetailPageProvider>().project;
}
