import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jtech_base/jtech_base.dart';

part 'config.g.dart';

part 'config.freezed.dart';

/*
* 全局设置
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ConfigProvider extends BaseConfigProvider<AppConfig> {
  ConfigProvider(super.context)
      : super(
            creator: (json) => AppConfig.fromJson(json),
            serializer: (e) => e.toJson());
}

// 配置文件对象
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig() = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}
