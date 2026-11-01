import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarpit/checker.dart';

/// Checks [source] without types, as for a project without `pub get`.
List<Finding> checkSource(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  return checkUnit(unit, source, 'a_test.dart', resolved: false);
}

void main() {
  group('widget test detection', () {
    test('finds testWidgets through an import prefix', () {
      final findings = checkSource('''
void main() {
  ft.testWidgets('x', (tester) async {
    await Future<void>.delayed(Duration.zero);
  });
}
''');
      expect(findings.single.rule, fakeDelay);
    });

    test('ignores a testWidgets method on some object', () {
      final findings = checkSource('''
void main() {
  helper.thing.testWidgets('x', (tester) async {
    await Future<void>.delayed(Duration.zero);
  });
}
''');
      expect(findings, isEmpty);
    });

    test('checks tarpitWidgets bodies too', () {
      final findings = checkSource('''
void main() {
  tarpitWidgets('x', (tester) async {
    await Future<void>.delayed(Duration.zero);
  });
}
''');
      expect(findings.single.rule, fakeDelay);
    });

    test('ignores a body passed by name', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', body);
}
Future<void> body(tester) async {
  await Future<void>.delayed(Duration.zero);
}
''');
      expect(findings, isEmpty);
    });
  });

  group('runAsync', () {
    test('exempts closures passed positionally', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
      sleep(Duration.zero);
    });
  });
}
''');
      expect(findings, isEmpty);
    });

    test('does not exempt the rest of the body', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await tester.runAsync(() async {});
    await Future<void>.delayed(Duration.zero);
  });
}
''');
      expect(findings.single.line, 4);
    });
  });

  test('a delay passed through Future.any is reported', () {
    final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await Future.any([tester.pump(), Future<void>.delayed(Duration.zero)]);
  });
}
''');
    expect(findings.single.rule, fakeDelay);
    expect(findings.single.column, 38);
  });

  test('return of a delay from an async body is reported', () {
    final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    return Future<void>.delayed(Duration.zero);
  });
}
''');
    expect(findings.single.severity, Severity.error);
  });

  test('without types, sleep is a guess and only info', () {
    final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    sleep(const Duration(seconds: 1));
  });
}
''');
    expect(findings.single.rule, blockingSleep);
    expect(findings.single.severity, Severity.info);
    expect(findings.single.message, contains('flutter pub get'));
  });

  test('without types, an unknown readAsString is not reported', () {
    final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await repository.readAsString();
  });
}
''');
    expect(findings, isEmpty);
  });

  group('endless-settle', () {
    test('only the next statement is a warning', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await tester.pumpWidget(CircularProgressIndicator());
    controller.finish();
    await tester.pumpAndSettle();
  });
}
''');
      expect(findings.single.severity, Severity.info);
      expect(findings.single.message, contains('line 3'));
    });

    test('a later pumpWidget without an indicator clears it', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await tester.pumpWidget(LinearProgressIndicator());
    await tester.pumpWidget(Text('done'));
    await tester.pumpAndSettle();
  });
}
''');
      expect(findings, isEmpty);
    });

    test('value: null is still indeterminate', () {
      final findings = checkSource('''
void main() {
  testWidgets('x', (tester) async {
    await tester.pumpWidget(LinearProgressIndicator(value: null));
    await tester.pumpAndSettle();
  });
}
''');
      expect(findings.single.severity, Severity.warning);
    });
  });
}
