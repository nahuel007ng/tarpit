# Fixtures

Invented widget tests that the checker tests run tarpit on. They are not
run as tests themselves (no `_test.dart` suffix) and are excluded from
`dart analyze`.

Each expected finding is written on its line as
`// expect: <rule-id> <severity>`, or, where the line is itself a comment,
anywhere in the file as `// expect-at <line>: <rule-id> <severity>`. A file
must produce exactly the findings it expects. Rule fixtures start with
`// dart format off` so the formatter cannot move an expectation to
another line.

`runtime/` holds widget tests for the watchdog that are expected to stall;
`test/runtime/watchdog_e2e_test.dart` runs them in a separate `flutter test`
process.
