import 'dart:async';

import 'package:tarpit/tarpit.dart';

/// flutter_test runs this around every test file in this directory.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Tarpit.stallAfter = const Duration(seconds: 20); // Duration.zero turns it off
  await testMain();
}
