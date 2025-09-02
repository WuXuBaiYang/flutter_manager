import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test', (tester) async {
    final e = 'dart run build_runner build';
    final e1 = e.split(' ').first;
    final e2 = e.split(' ').sublist(1).join(' ');
    print('$e1 $e2');
  });
}
