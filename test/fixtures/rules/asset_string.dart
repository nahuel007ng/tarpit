// dart format off
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads a text asset', (tester) async {
    await rootBundle.loadString('assets/terms.txt'); // expect: asset-string info
  });

  testWidgets('safe uses', (tester) async {
    await tester.runAsync(() => rootBundle.loadString('assets/terms.txt'));
    await rootBundle.load('assets/terms.txt');
  });
}
