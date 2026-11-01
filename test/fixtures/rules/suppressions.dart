// dart format off
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('suppressed on the line', (tester) async {
    await Future<void>.delayed(Duration.zero); // tarpit:allow fake-delay a fake timer callback pumps for us
  });

  testWidgets('suppressed from the line above', (tester) async {
    // tarpit:allow real-io,fake-delay the file is a pipe that answers at once
    await File('x').exists();
  });

  testWidgets('bad suppressions are reported and ignored', (tester) async {
    // tarpit:allow fake-delay
    await Future<void>.delayed(Duration.zero); // expect: fake-delay error
    // tarpit:allow no-such-rule it is fine
    sleep(Duration.zero); // expect: blocking-sleep warning
    // tarpit:allow
    await pumpEventQueue(); // tarpit:allow real-io wrong rule, so fake-delay is still reported
  });
}

// Findings on comment lines cannot carry an inline expectation:
// expect-at 17: bad-suppression warning
// expect-at 19: bad-suppression warning
// expect-at 21: bad-suppression warning
// expect-at 22: fake-delay error
