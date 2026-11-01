import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tarpit/checker.dart';

import '../support/sdk.dart';

final _inline = RegExp(r'//\s*expect:\s*([a-z-]+)\s+(error|warning|info)\s*$');
final _at = RegExp(
  r'^//\s*expect-at\s+(\d+):\s*([a-z-]+)\s+(error|warning|info)',
);

/// The findings a fixture declares, as `line rule severity` strings.
Set<String> expectations(File file) {
  final expected = <String>{};
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    final at = _at.firstMatch(line);
    if (at != null) {
      expected.add('${at[1]} ${at[2]} ${at[3]}');
      continue;
    }
    final inline = _inline.firstMatch(line);
    if (inline != null) expected.add('${i + 1} ${inline[1]} ${inline[2]}');
  }
  return expected;
}

void main() {
  final fixtures =
      Directory('test/fixtures/rules')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  late CheckResult result;

  setUpAll(() async {
    result = await Checker(
      sdkPath: dartSdk(),
    ).check([for (final f in fixtures) f.path]);
  });

  for (final fixture in fixtures) {
    final name = p.basename(fixture.path);
    test('$name reports exactly the expected findings', () {
      final shown = p.relative(fixture.path);
      final actual = {
        for (final f in result.findings)
          if (f.path == shown) '${f.line} ${f.rule.id} ${f.severity.name}',
      };
      expect(actual, expectations(fixture));
    });
  }

  test('fixtures resolve, except the one that must not', () {
    expect(result.untyped, [
      p.join('test', 'fixtures', 'rules', 'untyped.dart'),
    ]);
  });

  test('every rule is triggered at its default severity by some fixture', () {
    for (final rule in allRules) {
      expect(
        result.findings.any(
          (f) => f.rule == rule && f.severity == rule.severity,
        ),
        isTrue,
        reason: '${rule.id} has no positive fixture',
      );
    }
  });

  test('every rule has a negative case: a fixture with "safe uses"', () {
    for (final fixture in fixtures) {
      final name = p.basenameWithoutExtension(fixture.path);
      final rule = ruleById(name.replaceAll('_', '-'));
      if (rule == null) continue;
      expect(
        fixture.readAsStringSync(),
        contains("'safe uses'"),
        reason: '$name has no safe uses',
      );
    }
  });
}
