import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('description', () async {
    final a = ['a', 'b', 'c'];
    print(a..insert(a.indexOf('c')+2, 'd'));
  });
}
