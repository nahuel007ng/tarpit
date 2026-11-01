// dart format off
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sleeps', (tester) async {
    sleep(const Duration(milliseconds: 50)); // expect: blocking-sleep warning
    await tester.pump();
    void wait() => sleep(const Duration(milliseconds: 1)); // expect: blocking-sleep info
    wait();
  });

  test('a plain test may sleep', () {
    sleep(const Duration(milliseconds: 1));
  });

  testWidgets('safe uses', (tester) async {
    // A local function called sleep is not dart:io's.
    void sleep(Duration d) {}
    sleep(Duration.zero);
  });
}
