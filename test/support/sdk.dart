import 'dart:io';

import 'package:path/path.dart' as p;

/// The Dart SDK for the analyzer when tests run under `flutter test`.
///
/// The test process is flutter_tester, not `dart`, so the analyzer cannot
/// find the SDK from the running executable.
String dartSdk() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final sdk = p.join(flutterRoot, 'bin', 'cache', 'dart-sdk');
    if (Directory(sdk).existsSync()) return sdk;
  }
  final which = Process.runSync('which', ['dart']).stdout.toString().trim();
  if (which.isEmpty) {
    throw StateError('Set FLUTTER_ROOT or put dart on PATH to run the tests.');
  }
  final root = p.dirname(p.dirname(File(which).resolveSymbolicLinksSync()));
  // `dart` on PATH is often flutter/bin/dart, a script in front of the SDK.
  final bundled = p.join(root, 'bin', 'cache', 'dart-sdk');
  return Directory(bundled).existsSync() ? bundled : root;
}
