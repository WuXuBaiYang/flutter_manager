import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:jtech_base/jtech_base.dart';
import 'empty_box.dart';

// 文件拖拽回调
typedef DropFileValidator<T> = Future<String?> Function(T value);

/*
* 文件拖拽组件
* @author wuxubaiyang
* @Time 2023/11/29 10:31
*/
class DropFileView extends ProviderView {
  // 拖拽进入校验回调
  final DropFileValidator<Offset>? onEnterValidator;

  // 拖拽退出校验回调
  final DropFileValidator<Offset>? onExitValidator;

  // 拖拽更新校验回调
  final DropFileValidator<Offset>? onUpdateValidator;

  // 拖拽完成校验回调
  final DropFileValidator<List<String>> onDoneValidator;

  // 子元素
  final Widget child;

  // 默认提示
  final String hint;

  // 延迟退出时间
  final Duration delayExit;

  // 是否启用
  final bool enable;

  const DropFileView({
    super.key,
    required this.child,
    required this.onDoneValidator,
    this.enable = true,
    this.onEnterValidator,
    this.onExitValidator,
    this.onUpdateValidator,
    this.hint = '放到此处',
    this.delayExit = const Duration(seconds: 1),
  });

  @override
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(
            create: (context) => DropFileViewProvider(context)),
      ];

  @override
  Widget buildWidget(BuildContext context) {
    final provider = context.read<DropFileViewProvider>();
    return DropTarget(
        enable: enable,
        onDragEntered: (details) async {
          final message = await onEnterValidator?.call(details.globalPosition);
          provider.updateDropState(message != null, message ?? hint);
        },
        onDragExited: (details) async {
          final message = await onExitValidator?.call(details.globalPosition);
          provider.updateWarningState(message);
          if (message != null) await Future.delayed(delayExit);
          provider.dropExited();
        },
        onDragUpdated: (details) async {
          if (onUpdateValidator == null) return;
          final message = await onUpdateValidator?.call(details.globalPosition);
          provider.updateDropState(message != null, message ?? hint);
        },
        onDragDone: (details) async {
          final paths = details.files.map((e) => e.path).toList();
          final message = await onDoneValidator.call(paths);
          provider.updateWarningState(message);
          if (message != null) await Future.delayed(delayExit);
          provider.dropExited();
        },
        child: Selector<DropFileViewProvider, FileDropStateTuple?>(
          selector: (_, provider) => provider.dropState,
          builder: (_, dropState, __) {
            final color = dropState?.warning == true
                ? Colors.red.withOpacity(0.25)
                : null;
            return EmptyBoxView(
              color: color,
              isEmpty: dropState != null,
              hint: dropState?.message ?? hint,
              child: child,
            );
          },
        ));
  }
}

// 文件拖拽状态元组
typedef FileDropStateTuple = ({bool warning, String message});

/*
* 文件拖拽组件状态管理
* @author wuxubaiyang
* @Time 2023/11/29 10:32
*/
class DropFileViewProvider extends BaseProvider {
  // 文件拖拽状态
  FileDropStateTuple? _dropState;

  // 获取文件拖拽状态
  FileDropStateTuple? get dropState => _dropState;

  DropFileViewProvider(super.context);

  // 更新拖拽状态
  void updateDropState(bool warning, String message) {
    _dropState = (warning: warning, message: message);
    notifyListeners();
  }

  // 更新异常状态
  void updateWarningState(String? message) {
    if (message != null) updateDropState(true, message);
  }

  // 文件拖拽退出区域
  void dropExited() {
    _dropState = null;
    notifyListeners();
  }
}
