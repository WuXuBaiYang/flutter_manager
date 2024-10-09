import 'package:flutter/cupertino.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 设置提供者
* @author wuxubaiyang
* @Time 2023/11/28 10:54
*/
class SettingProvider extends BaseProvider {
  // 设置项key
  final environmentKey = GlobalObjectKey(genDateSign()),
      environmentCacheKey = GlobalObjectKey(genDateSign()),
      projectPlatformSortKey = GlobalObjectKey(genDateSign()),
      themeModeKey = GlobalObjectKey(genDateSign()),
      themeSchemeKey = GlobalObjectKey(genDateSign());

  // 选中的设置项key
  GlobalObjectKey? _selectedKey;

  // 获取选中的key
  GlobalObjectKey? get selectedKey => _selectedKey;

  SettingProvider(super.context);

  // 跳转到flutter环境设置
  void goEnvironment() => _goSetting(environmentKey);

  // 跳转到flutter环境缓存设置
  void goEnvironmentCache() => _goSetting(environmentCacheKey);

  // 跳转到项目平台排序设置
  void goProjectPlatformSort() => _goSetting(projectPlatformSortKey);

  // 跳转到配色模式设置
  void goThemeMode() => _goSetting(themeModeKey);

  // 跳转到配色方案设置
  void goThemeScheme() => _goSetting(themeSchemeKey);

  // 取消选中
  void cancelSelected() {
    _selectedKey = null;
    notifyListeners();
  }

  // 跳转到指定设置项
  void _goSetting(GlobalObjectKey key) {
    _selectedKey = key;
    notifyListeners();
  }
}
