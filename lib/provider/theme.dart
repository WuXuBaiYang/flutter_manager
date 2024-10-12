import 'package:flutter/material.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 主题提供者
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ThemeProvider extends BaseThemeProvider {
  ThemeProvider(super.context);

  @override
  ThemeData customTheme(ThemeData themeData, Brightness brightness) {
    return themeData.copyWith(
      focusColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        color: brightness == Brightness.light ? Colors.white : Colors.black,
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 0.3,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
      ),
      searchBarTheme: const SearchBarThemeData(
        elevation: WidgetStatePropertyAll(2),
        constraints: BoxConstraints.tightFor(height: 45),
      ),
      tabBarTheme: const TabBarTheme(
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
}
