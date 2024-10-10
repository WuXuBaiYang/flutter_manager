import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_manager/main.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 设置项子项
* @author wuxubaiyang
* @Time 2023/11/28 11:18
*/
class SettingItem extends StatefulWidget {
  // 别名
  final String label;

  // 内容体
  final Widget? content;

  // 子元素
  final Widget? child;

  // 最大闪烁次数
  final int maxBlinkCount;

  const SettingItem({
    required super.key,
    required this.label,
    this.child,
    this.content,
    this.maxBlinkCount = 2,
  });

  @override
  State<StatefulWidget> createState() => _SettingItem();
}

/*
* 设置项子项状态
* @author wuxubaiyang
* @Time 2023/11/29 12:05
*/
class _SettingItem extends State<SettingItem> {
  // 缓存计时器
  Timer? _timer;

  // 选中状态
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Selector<SettingProvider, Key?>(
      selector: (_, provider) => provider.selectedKey,
      builder: (_, key, __) {
        if (key == widget.key) _startTimer(context);
        return ListTile(
          selected: _selected,
          trailing: widget.child,
          subtitle: widget.content,
          title: Text(widget.label),
          selectedColor: Colors.transparent,
          isThreeLine: widget.content != null,
        );
      },
    );
  }

  // 启动定时器刷新
  void _startTimer(BuildContext context) {
    if (_timer != null) return;
    var times = 0;
    const duration = Duration(milliseconds: 400);
    _timer = Timer.periodic(duration, (t) {
      setState(() => _selected = !_selected);
      if (++times > widget.maxBlinkCount * 2 - 1) {
        context.setting.cancelSelected();
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
