import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarpit/checker.dart';

void main() {
  final readme = File('README.md').readAsStringSync();
  final rulesDoc = File('doc/rules.md').readAsStringSync();
  final changelog = File('CHANGELOG.md').readAsStringSync();

  for (final rule in allRules) {
    test('${rule.id} is documented', () {
      expect(readme, contains('`${rule.id}`'));
      expect(rulesDoc, contains('## ${rule.id}'));
      expect(changelog, contains('`${rule.id}`'));
    });
  }

  test('the CHANGELOG has an entry for the current version', () {
    expect(changelog, contains('## $packageVersion'));
  });
}
