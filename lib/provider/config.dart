import 'package:jtech_base/jtech_base.dart';

/*
* 全局设置
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ConfigProvider extends BaseConfigProvider<AppConfig> {
  ConfigProvider(super.context) : super(creator: AppConfig.from);
}

/*
* 配置文件对象
* @author wuxubaiyang
* @Time 2024/8/14 14:40
*/
class AppConfig extends BaseConfig {
  AppConfig();

  AppConfig.from(obj);

  @override
  Map<String, dynamic> to() => {};

  @override
  AppConfig copyWith() {
    return AppConfig();
  }
}
