// dart format off
// The import below does not resolve, so the file is checked by name only.
import 'package:flutter_test/not_a_real_library.dart';

void main() {
  testWidgets('guesses by name', (tester) async {
    await Future<void>.delayed(Duration.zero); // expect: fake-delay error
    await compute(work, 1); // expect: isolate-hop info
    await image.toByteData(); // expect: engine-async info
    await something.readAsString();
  });
}
