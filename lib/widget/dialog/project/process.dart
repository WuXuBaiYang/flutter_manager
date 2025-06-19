import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_manager/tool/template.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:flutter_manager/model/create_template.dart';

// 展示模板项目创建日志进度弹窗
Future<String?> showTemplateCreateProcess(
  BuildContext context, {
  required CreateTemplate template,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => TemplateCreateProcessView(template: template),
  );
}

/*
* 模板项目创建日志进度弹窗
* @author wuxubaiyang
* @Time 2025/6/19 9:54
*/
class TemplateCreateProcessView
    extends ProviderView<TemplateCreateProcessProvider> {
  // 模板
  final CreateTemplate template;

  TemplateCreateProcessView({super.key, required this.template});

  @override
  TemplateCreateProcessProvider createProvider(BuildContext context) =>
      TemplateCreateProcessProvider(context, template);

  @override
  Widget buildWidget(BuildContext context) {
    return CustomDialog(
      title: Text('创建进度'),
      content: createSelector(
        selector: (_, p) => p.showLog,
        builder: (_, showLog, _) {
          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 240, height: 240),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: provider.toggleLog,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    showLog ? Icons.checklist_rounded : Icons.message_rounded,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: showLog ? _buildLogs() : _buildStepList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        createSelector(
          selector: (_, p) => p.isFinished,
          builder: (_, isFinished, _) {
            if (!isFinished) return SizedBox();
            return TextButton(onPressed: context.pop, child: Text('关闭'));
          },
        ),
      ],
    );
  }

  // 构建步骤列表
  Widget _buildStepList() {
    final iconSize = 14.0;
    return createSelector(
      selector: (_, p) => p.steps,
      builder: (_, steps, _) {
        return ListView.builder(
          itemCount: steps.length,
          // shrinkWrap: true,
          itemBuilder: (_, i) {
            final item = steps[i];
            final color = switch (item.state) {
              CreateStepState.ongoing => Colors.greenAccent,
              CreateStepState.finish => Colors.greenAccent,
              CreateStepState.error => Colors.redAccent,
            }.shade200;
            final icon = switch (item.state) {
              CreateStepState.ongoing => CircularProgressIndicator(
                color: color,
                strokeWidth: 2,
                constraints: BoxConstraints.tightFor(
                  width: iconSize - 2,
                  height: iconSize - 2,
                ),
              ),
              CreateStepState.error => Icon(
                Icons.error_outline_rounded,
                color: color,
                size: iconSize,
              ),
              CreateStepState.finish => Icon(
                Icons.check_circle_rounded,
                color: color,
                size: iconSize,
              ),
            };
            return Padding(
              padding: EdgeInsets.only(left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i != 0)
                    SizedBox.fromSize(
                      size: Size(iconSize, 24),
                      child: VerticalDivider(
                        color: color,
                        width: 2,
                        indent: 8,
                        endIndent: 4,
                        thickness: 2,
                        radius: BorderRadius.circular(8),
                      ),
                    ),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(child: icon),
                        WidgetSpan(child: SizedBox(width: 8)),
                        TextSpan(
                          text: item.message,
                          style: TextTheme.of(context).bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 构建日志
  Widget _buildLogs() {
    return Container(
      color: Colors.black,
      width: double.maxFinite,
      height: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: createSelector(
        selector: (_, p) => p.log,
        builder: (_, log, _) {
          return SingleChildScrollView(
            controller: provider.logScrollController,
            child: Text(log, style: TextStyle(color: Colors.white70)),
          );
        },
      ),
    );
  }
}

class TemplateCreateProcessProvider extends BaseProvider {
  // 日志流控制器
  final _logStreamController = StreamController<String>.broadcast();

  // 日志滚动控制器
  final logScrollController = ScrollController();

  // 创建步骤列表
  List<CreateStep> steps = [];

  // 日志流
  Stream<String> get logStream => _logStreamController.stream;

  // 是否已结束
  bool isFinished = false;

  // 当前展示步骤/日志
  bool showLog = false;

  // 日志消息
  String log = '';

  TemplateCreateProcessProvider(super.context, CreateTemplate template) {
    // 启动模板创建脚本
    startTemplateCreate(template);
    // 监听log流并实时添加到日志中
    logStream.listen((e) {
      log += e;
      notifyListeners();
      logScrollController.jumpTo(logScrollController.position.maxScrollExtent);
    });
  }

  // 切换日志展示
  void toggleLog() {
    showLog = !showLog;
    notifyListeners();
  }

  // 启动模板创建脚本
  void startTemplateCreate(CreateTemplate template) async {
    try {
      final result = await TemplateCreate.start(
        template,
        onCreateStep: (v) {
          steps = v;
          notifyListeners();
        },
        onLog: _logStreamController.sink,
      );
      if (result == null || !context.mounted) {
        return showNoticeError('创建失败，请重试');
      }
      context.pop(result);
    } catch (e) {
      showNoticeError('创建失败：${e.toString()}');
    } finally {
      isFinished = true;
      notifyListeners();
    }
  }
}
