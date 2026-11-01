@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Runs test/fixtures/runtime/stalls.dart in a separate `flutter test`
/// process, the way CI would, and reads its JSON reporter output.
void main() {
  test(
    'stalled tests fail fast with a diagnostic; the next test passes',
    () async {
      final root = Platform.environment['FLUTTER_ROOT'];
      final flutter = root == null ? 'flutter' : p.join(root, 'bin', 'flutter');
      final real = Stopwatch()..start();
      final result = await Process.run(flutter, [
        'test',
        '--no-pub',
        '--reporter',
        'json',
        p.join('test', 'fixtures', 'runtime', 'stalls.dart'),
      ]);
      real.stop();

      final names = <int, String>{};
      final outcomes = <String, String>{};
      final errors = <String, String>{};
      for (final line in const LineSplitter().convert('${result.stdout}')) {
        if (!line.startsWith('{')) continue;
        final event = jsonDecode(line) as Map<String, Object?>;
        switch (event['type']) {
          case 'testStart':
            final test = event['test']! as Map<String, Object?>;
            names[test['id']! as int] = test['name']! as String;
          case 'print':
            final name = names[event['testID']]!;
            errors[name] = '${errors[name] ?? ''}${event['message']}\n';
          case 'error':
            final name = names[event['testID']]!;
            errors[name] = '${errors[name] ?? ''}${event['error']}\n';
          case 'testDone':
            outcomes[names[event['testID']]!] = event['result']! as String;
        }
      }

      expect(result.exitCode, 1, reason: '${result.stderr}');
      expect(outcomes['stalls on a fake delay'], isNot('success'));
      expect(outcomes['stalls on a never-ending future'], isNot('success'));
      expect(outcomes['runs after the stalls'], 'success');
      expect(
        errors['stalls on a fake delay'],
        contains('"stalls on a fake delay" made no progress for 0.5s'),
      );
      // Two 0.5 s stalls plus tool start-up, far below any CI timeout.
      expect(real.elapsed, lessThan(const Duration(minutes: 2)));
    },
  );
}
