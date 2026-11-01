# tarpit example

`lib/greeting_card.dart` is a small widget. `test/stalls_test.dart` tests it
in three ways that stall or fail inside FakeAsync; `test/fixed_test.dart` is
the same three tests written so they pass.

```sh
flutter pub get
dart run tarpit                        # 3 findings in stalls_test.dart, exit 1
flutter test test/fixed_test.dart      # passes
flutter test test/stalls_test.dart     # fails in seconds instead of hanging
```

`stalls_test.dart` imports `package:tarpit/flutter_test.dart`, so its
`testWidgets` run under the watchdog, and `test/flutter_test_config.dart`
sets the limit for the whole directory.
