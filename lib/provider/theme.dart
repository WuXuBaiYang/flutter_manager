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
  ThemeData createTheme(ThemeData themeData, Brightness brightness) {
    final cardColor =
        brightness == Brightness.light ? Colors.white : Colors.black;
    return themeData.copyWith(
      focusColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardColor,
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
        backgroundColor: WidgetStatePropertyAll(cardColor),
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
}
