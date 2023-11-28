import 'dart:async';
import 'package:flutter_manager/common/provider.dart';

// 设置项下标元组
typedef SettingIndexTuple = ({int? index, List<int> subIndexs});

/*
* 设置提供者
* @author wuxubaiyang
* @Time 2023/11/28 10:54
*/
class SettingProvider extends BaseProvider {
  // 事件销毁延迟
  final Duration clearDelay = const Duration(milliseconds: 800);

  // 选中的设置项下标元组
  SettingIndexTuple? _indexTuple;

  // 获取选中的设置项下标元组
  SettingIndexTuple? get indexTuple => _indexTuple;

  // 跳转到flutter环境设置
  void goEnvironmentAdd() => goSetting((index: 0, subIndexs: [1]));

  // 跳转到指定设置项
  void goSetting(SettingIndexTuple indexTuple) {
    _indexTuple = indexTuple;
    // 一定时间后销毁此次事件
    Timer.periodic(clearDelay, (t) {
      clear();
      t.cancel();
    });
    notifyListeners();
  }

  // 清除设置项
  void clear() {
    _indexTuple = null;
    notifyListeners();
  }
}
