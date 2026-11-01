// dart format off
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('awaits a delay', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await Future<void>.delayed(const Duration(milliseconds: 10)); // expect: fake-delay error
    await Future.delayed(Duration.zero); // expect: fake-delay error
    await Future<void>(() {}); // expect: fake-delay error
    await pumpEventQueue(); // expect: fake-delay error
    await Future.delayed(Duration.zero).timeout(const Duration(seconds: 1)); // expect: fake-delay error
    await Future.wait([
      Future<void>.delayed(Duration.zero), // expect: fake-delay error
      tester.pump(),
    ]);
  });

  testWidgets('returns a delay', (tester) => Future<void>.delayed(Duration.zero)); // expect: fake-delay error

  testWidgets('delay inside a closure', (tester) async {
    Future<void> later() async {
      await Future<void>.delayed(Duration.zero); // expect: fake-delay info
    }

    await tester.pumpWidget(GestureDetector(onTap: later));
  });

  testWidgets('safe uses', (tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await Future<void>.value();
    await Future<void>.microtask(() {});
    // Not awaited: a pending timer, which flutter_test reports by itself.
    Future<void>.delayed(Duration.zero).ignore();
  });

  test('plain tests are not widget tests', () async {
    await Future<void>.delayed(Duration.zero);
  });
}
