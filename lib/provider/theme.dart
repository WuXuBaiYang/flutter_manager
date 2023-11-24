import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/model/theme_scheme.dart';

/*
* 主题管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ThemeProvider extends BaseProvider {
  // 当前主题模式缓存key
  static const String _themeModeKey = 'themeMode';

  // 当前主题配色方案缓存key
  static const String _themeSchemeKey = 'themeScheme';

  // 默认主题模式
  static const ThemeMode _defaultThemeMode = ThemeMode.system;

  // 默认主题配色方案
  static const FlexScheme _defaultThemeScheme = FlexScheme.blueM3;

  // 缓存配色方案
  FlexScheme? _scheme;

  // 缓存当前主题模式
  ThemeMode? _themeMode;

  // 缓存当前主题数据
  ThemeData? _themeData;

  // 缓存暗色主题数据
  ThemeData? _darkThemeData;

  // 获取当前主题模式
  ThemeMode get themeMode => _themeMode ??=
      ThemeMode.values[cache.getInt(_themeModeKey) ?? _defaultThemeMode.index];

  // 获取暗色主题
  ThemeData get darkThemeData =>
      _darkThemeData ??= _genThemeData(Brightness.dark);

  // 获取主题色
  Color getPrimary(BuildContext context) => getThemeData(context).primaryColor;

  // 获取主标题文本样式
  TextStyle? getPrimaryTitleStyle(BuildContext context) =>
      getThemeData(context).textTheme.headlineLarge;

  // 获取次标题文本样式
  TextStyle? getSecondaryTitleStyle(BuildContext context) =>
      getThemeData(context).textTheme.headlineMedium;

  // 获取主文本样式
  TextStyle? getPrimaryStyle(BuildContext context) =>
      getThemeData(context).textTheme.bodyLarge;

  // 获取次文本样式
  TextStyle? getSecondaryStyle(BuildContext context) =>
      getThemeData(context).textTheme.bodyMedium;

  // 获取当前主题数据
  ThemeData getThemeData(BuildContext context) =>
      _themeData ??= _genThemeData(getBrightness(context));

  // 获取当前主题亮度
  Brightness getBrightness(BuildContext context) => {
        ThemeMode.light: Brightness.light,
        ThemeMode.dark: Brightness.dark,
        ThemeMode.system: MediaQuery.of(context).platformBrightness,
      }[themeMode]!;

  // 切换主题模式
  Future<void> changeThemeMode(
      BuildContext context, ThemeMode themeMode) async {
    _themeMode = themeMode;
    cache.setInt(_themeModeKey, _themeMode!.index);
    _updateThemeData(context);
  }

  // 切换主题配色方案
  Future<void> changeThemeScheme(
      BuildContext context, ThemeSchemeModel schemeModel) async {
    _scheme = schemeModel.scheme;
    cache.setInt(_themeSchemeKey, _scheme!.index);
    _updateThemeData(context);
  }

  // 更新主题数据
  Future<void> _updateThemeData(BuildContext context) async {
    _themeData = _genThemeData(getBrightness(context));
    _darkThemeData = _genThemeData(Brightness.dark);
    notifyListeners();
  }

  // 获取全部支持的配色方案
  List<ThemeSchemeModel> getThemeSchemeList(BuildContext context,
      {bool useMaterial3 = true}) {
    final brightness = getBrightness(context);
    const schemesMap = FlexColor.schemesWithCustom;
    return FlexScheme.values
        .where((e) {
          if (e == FlexScheme.custom) return false;
          if (useMaterial3) return e.name.contains('M3');
          return !e.name.contains('M3');
        })
        .map((scheme) => ThemeSchemeModel.fromScheme(scheme,
            schemeColor: {
              Brightness.light: schemesMap[scheme]!.light,
              Brightness.dark: schemesMap[scheme]!.dark,
            }[brightness]!))
        .toList();
  }

  // 获取当前的主题配色方案
  ThemeSchemeModel getThemeSchemeModel(BuildContext context) {
    const schemesMap = FlexColor.schemesWithCustom;
    return ThemeSchemeModel.fromScheme(_themeScheme,
        schemeColor: {
          Brightness.light: schemesMap[_themeScheme]!.light,
          Brightness.dark: schemesMap[_themeScheme]!.dark,
        }[getBrightness(context)]!);
  }

  // 获取主题配色方案
  FlexScheme get _themeScheme => _scheme ??= FlexScheme
      .values[cache.getInt(_themeSchemeKey) ?? _defaultThemeScheme.index];

  // 根据主题亮度生成不同的主题数据
  ThemeData _genThemeData(Brightness brightness) {
    final themeData = {
      Brightness.light: FlexThemeData.light(
        scheme: _themeScheme,
        useMaterial3: true,
      ),
      Brightness.dark: FlexThemeData.dark(
        scheme: _themeScheme,
        useMaterial3: true,
      ),
    }[brightness]!;
    return themeData.copyWith(
      /// 在此处自定义组件样式
      cardTheme: const CardTheme(
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
