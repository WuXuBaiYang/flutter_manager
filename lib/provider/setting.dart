import 'dart:async';
import 'package:flutter_manager/common/provider.dart';

/*
* 设置提供者
* @author wuxubaiyang
* @Time 2023/11/28 10:54
*/
class SettingProvider extends BaseProvider {
  // 闪烁间隔
  final _blinkingDelay = const Duration(milliseconds: 300);

  // 闪烁次数
  final _blinkingCount = 5;

  // 选中的设置项下标
  int? _index;

  // 获取选中的设置项下标元组
  int? get index => _index;

  // 跳转到flutter环境设置
  void goEnvironment() => goSetting(0);

  // 跳转到配色模式设置
  void goThemeMode() => goSetting(1);

  // 跳转到配色方案设置
  void goThemeScheme() => goSetting(2);

  // 跳转到指定设置项
  void goSetting(int index) {
    // 一定时间后销毁此次事件
    Timer.periodic(_blinkingDelay, (t) {
      t.tick % 2 == 0 ? _selected(index) : _unselected();
      if (t.tick >= _blinkingCount) t.cancel();
    });
  }

  // 设置项选中
  void _selected(int index) {
    _index = index;
    notifyListeners();
  }

  // 取消选中
  void _unselected() {
    _index = null;
    notifyListeners();
  }
}
