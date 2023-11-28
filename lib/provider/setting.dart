import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/tool/tool.dart';

/*
* 设置提供者
* @author wuxubaiyang
* @Time 2023/11/28 10:54
*/
class SettingProvider extends BaseProvider {
  // 闪烁间隔
  final _blinkingDelay = const Duration(milliseconds: 500);

  // 闪烁次数(9=4次)
  final _blinkingCount = 9;

  // 选中的设置项key
  GlobalObjectKey? _selectedKey;

  // 获取选中的key
  GlobalObjectKey? get selectedKey => _selectedKey;

  // 设置项key
  final environmentKey = GlobalObjectKey(Tool.genID()),
      themeModeKey = GlobalObjectKey(Tool.genID()),
      themeSchemeKey = GlobalObjectKey(Tool.genID());

  // 跳转到flutter环境设置
  void goEnvironment() => _goSetting(environmentKey);

  // 跳转到配色模式设置
  void goThemeMode() => _goSetting(themeModeKey);

  // 跳转到配色方案设置
  void goThemeScheme() => _goSetting(themeSchemeKey);

  // 跳转到指定设置项
  void _goSetting(GlobalObjectKey key) {
    // 一定时间后销毁此次事件
    Timer.periodic(_blinkingDelay, (t) {
      _selectedKey = t.tick % 2 == 0 ? key : null;
      if (t.tick >= _blinkingCount) t.cancel();
      notifyListeners();
    });
  }
}
