// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_manager/main.dart';

void main() {
  test('description', () {
    const des = 'Tools • Dart 3.2.0 • DevTools 2.28.2';
    // 正则匹配时间戳

    final reg = RegExp(r'DevTools (.*?)$');
    print(reg.firstMatch(des)?.group(1));
  });
}
