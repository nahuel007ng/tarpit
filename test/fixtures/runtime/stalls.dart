// Run by test/runtime/watchdog_e2e_test.dart in its own `flutter test`
// process. The first two tests are meant to fail through the watchdog.
import 'package:tarpit/flutter_test.dart';

void main() {
  Tarpit.stallAfter = const Duration(milliseconds: 500);

  testWidgets('stalls on a fake delay', (tester) async {
    await Future<void>.delayed(const Duration(minutes: 1));
  });

  testWidgets('stalls on a never-ending future', (tester) async {
    await Future.any(<Future<void>>[]);
  });

  testWidgets('runs after the stalls', (tester) async {
    await tester.pump(const Duration(seconds: 1));
  });
}
