import 'package:flutter_manager/common/provider.dart';

/*
* 设置提供者
* @author wuxubaiyang
* @Time 2023/11/28 10:54
*/
class SettingProvider extends BaseProvider {
  // 设置项的指定位置
  int? _index;

  // 获取设置项的指定位置
  int? get index => _index;

  // 设置项子项位置
  int? _subIndex;

  // 获取设置项子项位置
  int? get subIndex => _subIndex;

  // 跳转到flutter环境设置
  void goEnvironmentAdd() {
    _index = 0;
    _subIndex = 1;
    notifyListeners();
  }

  // 清除设置项
  void clear() {
    _index = null;
    _subIndex = null;
    notifyListeners();
  }
}
