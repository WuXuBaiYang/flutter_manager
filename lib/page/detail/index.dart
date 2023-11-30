import 'package:flutter/material.dart';
import 'package:flutter_manager/common/page.dart';
import 'package:flutter_manager/manage/router.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/widget/empty_box.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 项目详情页路由传参元组
typedef ProjectDetailRouteTuple = ({Project project});

/*
* 项目详情页
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPage extends BasePage {
  const ProjectDetailPage({super.key});

  @override
  List<SingleChildWidget> getProviders(BuildContext context) => [
        ChangeNotifierProvider(
          create: (_) => ProjectDetailPageProvider(context),
        ),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Selector<ProjectDetailPageProvider, Project?>(
        selector: (_, provider) => provider.project,
        builder: (_, project, __) {
          return EmptyBoxView(
            hint: '项目不存在',
            isEmpty: project == null,
            child: _buildContent(context),
          );
        },
      ),
    );
  }

  // 构建内容
  Widget _buildContent(BuildContext context) {
    return Container();
  }
}

/*
* 项目详情页状态管理
* @author wuxubaiyang
* @Time 2023/11/30 16:35
*/
class ProjectDetailPageProvider extends ChangeNotifier {
  // 缓存项目信息
  Project? _project;

  // 项目信息
  Project? get project => _project;

  ProjectDetailPageProvider(BuildContext context) {
    // 获取项目信息
    final arguments = router.findTuple<ProjectDetailRouteTuple>(context);
    _project = arguments?.project;
  }
}
