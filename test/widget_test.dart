// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_manager/main.dart';
import 'package:xml/xml.dart';

void main() {
  test('description', () {
    const path =
        'C:/Users/wuxubaiyang/Documents/Workspace/jtech_demo/android/app/src/main/AndroidManifest.xml';
    final content = File(path).readAsStringSync();
    final doc = XmlDocument.parse(content);
    final a = doc
        .getElement('manifest')
        ?.getElement('application')
        ?.getAttribute('android:icon');
    print('object');
  });
}
