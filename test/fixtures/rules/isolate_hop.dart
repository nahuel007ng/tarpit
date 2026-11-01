// dart format off
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

int square(int x) => x * x;

void main() {
  testWidgets('hops to an isolate', (tester) async {
    await compute(square, 3); // expect: isolate-hop error
    await Isolate.run(() => 1); // expect: isolate-hop error
    final port = ReceivePort();
    await Isolate.spawn(square, 2); // expect: isolate-hop error
    await port.first; // expect: isolate-hop error
  });

  testWidgets('safe uses', (tester) async {
    final result = await tester.runAsync(() => compute(square, 3));
    expect(result, 9);
    expect(square(3), 9);
  });
}
