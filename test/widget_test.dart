import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('description', () async {
    const path  = 'C:/Users/wuxubaiyang/Documents/Workspace/jtech_demo/android/app/build.gradle';
    var content = await File(path).readAsString();
    final reg = RegExp(r'applicationId "(.*)"');
    final temp = reg.pattern.replaceFirst('(.*)', 'com.jtech.a');
    content = content.replaceFirst(reg, temp.replaceAll('\\', ''));
    print('object');
  });
}
