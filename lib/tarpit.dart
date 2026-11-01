/// Runtime side of tarpit: a watchdog for widget tests.
///
/// Use `tarpitWidgets` in place of `testWidgets`, or import
/// `package:tarpit/flutter_test.dart` in place of
/// `package:flutter_test/flutter_test.dart` to put every `testWidgets` in
/// the file under the watchdog.
///
/// The static checker is in `package:tarpit/checker.dart` and the `tarpit`
/// command.
library;

export 'src/runtime/watchdog.dart'
    show Tarpit, TarpitStall, tarpitWidgets, watchTester;
