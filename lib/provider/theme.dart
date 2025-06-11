import 'package:flutter/material.dart';
import 'package:flutter_manager/widget/scheme_picker.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 主题提供者
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ThemeProvider extends BaseThemeProvider {
  ThemeProvider(super.context);

  @override
  ThemeData createTheme(ThemeData themeData, Brightness brightness) {
    return themeData.copyWith(
      focusColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 0.3,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStatePropertyAll(2),
        constraints: BoxConstraints.tightFor(height: 45),
        // backgroundColor: WidgetStatePropertyAll(cardColor),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerHeight: 0,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 2,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
        showValueIndicator: ShowValueIndicator.onlyForContinuous,
      ),
    );
  }

  @override
  CustomTheme? createCustomTheme(ThemeData themeData, Brightness brightness) {
    return CustomTheme(
      customDialogTheme: CustomDialogThemeData(
        style: CustomDialogStyle(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
        ),
      ),
    );
  }

  // 展示主题切换对话框
  Future<bool> showSchemePickerDialog(BuildContext context) async {
    final result = await showSchemePicker(context,
        current: scheme, themeSchemes: themeSchemes);
    return changeThemeScheme(result);
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
  String get label => switch (this) {
        ThemeMode.light => '浅色模式',
        ThemeMode.dark => '深色模式',
        ThemeMode.system => '跟随系统',
      };
}

/*
* 扩展亮度枚举类，添加中文名称属性
* @author wuxubaiyang
* @Time 2023/11/24 15:49
*/
extension BrightnessExtension on Brightness {
  // 获取亮度名称
  String get label => switch (this) {
        Brightness.light => '浅色',
        Brightness.dark => '深色',
      };
}
