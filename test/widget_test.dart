import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('description', () async {
    const path = 'assets/permission/android.json';
    final json = jsonDecode(await rootBundle.loadString(path));
    for (var e in json) {
      // e['value'] = e['name'];
    }
    final a = jsonEncode(json);
    print('object');
  });
}
