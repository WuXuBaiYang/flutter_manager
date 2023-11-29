import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/cache.dart';
import 'package:flutter_manager/model/theme_scheme.dart';

/*
* 主题提供者
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
      focusColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardTheme(
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.3,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
      ),
      searchBarTheme: const SearchBarThemeData(
        elevation: MaterialStatePropertyAll(2),
        constraints: BoxConstraints.tightFor(height: 45),
      ),
    );
  }
}

/*
* 扩展主题模式枚举类，添加中文名称属性
*
* @author wuxubaiyang
* @Time 2023/11/24 15:47
*/
extension ThemeModeExtension on ThemeMode {
  // 获取主题模式名称
  String get label => {
        ThemeMode.light: '浅色模式',
        ThemeMode.dark: '深色模式',
        ThemeMode.system: '跟随系统',
      }[this]!;
}

/*
* 扩展主题配色方案枚举类，添加中文名称属性
* @author wuxubaiyang
* @Time 2023/11/24 15:48
*/
extension FlexSchemeExtension on FlexScheme {
  // 获取主题配色方案名称
  String get label => {
        FlexScheme.redM3: '骚气红',
        FlexScheme.pinkM3: '温柔粉',
        FlexScheme.purpleM3: '高贵紫',
        FlexScheme.indigoM3: '宁静靛',
        FlexScheme.blueM3: '沉稳蓝',
        FlexScheme.cyanM3: '清新青',
        FlexScheme.tealM3: '苍翠绿',
        FlexScheme.greenM3: '清新绿',
        FlexScheme.limeM3: '活力黄绿',
        FlexScheme.yellowM3: '明亮黄',
        FlexScheme.orangeM3: '暖心橙',
        FlexScheme.deepOrangeM3: '深邃橙',
      }[this]!;
}

/*
* 扩展亮度枚举类，添加中文名称属性
* @author wuxubaiyang
* @Time 2023/11/24 15:49
*/
extension BrightnessExtension on Brightness {
  // 获取亮度名称
  String get label => {
        Brightness.light: '浅色',
        Brightness.dark: '深色',
      }[this]!;
}
