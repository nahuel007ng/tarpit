import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarpit/checker.dart';

List<Finding> checkSource(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  return checkUnit(unit, source, 'a_test.dart', resolved: false);
}

String body(String lines) =>
    '''
void main() {
  testWidgets('x', (tester) async {
$lines
  });
}
''';

void main() {
  test('a comment on the same line silences that rule', () {
    expect(
      checkSource(
        body(
          '    await Future<void>.delayed(Duration.zero); '
          '// tarpit:allow fake-delay pumped by a fake timer',
        ),
      ),
      isEmpty,
    );
  });

  test('a comment alone on a line silences the next line only', () {
    final findings = checkSource(
      body('''
    // tarpit:allow fake-delay pumped elsewhere
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);'''),
    );
    expect(findings.single.line, 5);
  });

  test('another rule id does not silence the finding', () {
    final findings = checkSource(
      body(
        '    await Future<void>.delayed(Duration.zero); '
        '// tarpit:allow real-io not this one',
      ),
    );
    expect(findings.single.rule, fakeDelay);
  });

  test('several ids may be listed with commas', () {
    final findings = checkSource(
      body('''
    // tarpit:allow fake-delay,blocking-sleep both are fine in this harness
    sleep(Duration.zero); await Future<void>.delayed(Duration.zero);'''),
    );
    expect(findings, isEmpty);
  });

  test('a missing reason is reported and the comment is ignored', () {
    final findings = checkSource(
      body(
        '    await Future<void>.delayed(Duration.zero); '
        '// tarpit:allow fake-delay',
      ),
    );
    expect(findings.map((f) => f.rule.id), ['fake-delay', 'bad-suppression']);
  });

  test('bad-suppression itself cannot be suppressed', () {
    final findings = checkSource(
      body('    // tarpit:allow bad-suppression because'),
    );
    expect(findings.single.rule, badSuppression);
    expect(findings.single.message, contains('Unknown rule id'));
  });

  test('allow-file silences a rule in the whole file', () {
    final source =
        '// tarpit:allow-file fake-delay this harness pumps from a timer\n'
        '${body('    await Future<void>.delayed(Duration.zero);')}';
    expect(checkSource(source), isEmpty);
  });

  test('the marker inside a string is not a suppression', () {
    final findings = checkSource(
      body(
        '    await Future<void>.delayed(Duration.zero, () => '
        "'// tarpit:allow fake-delay not a comment');",
      ),
    );
    expect(findings.single.rule, fakeDelay);
  });
}
