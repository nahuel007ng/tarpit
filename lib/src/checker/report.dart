import 'dart:convert';

import 'checker.dart';
import 'finding.dart';
import 'rules.dart';
import 'version.dart';

const _rulesDoc =
    'https://github.com/saimskywalker/tarpit/blob/main/doc/rules.md';

/// Human-readable report: one block per finding, the reason each rule
/// exists (once per rule), then a summary line.
String textReport(CheckResult result) {
  final out = StringBuffer();
  final seen = <Rule>[];
  for (final f in result.findings) {
    if (!seen.contains(f.rule)) seen.add(f.rule);
    out
      ..writeln(
        '${f.path}:${f.line}:${f.column}  ${f.severity.name}  ${f.rule.id}',
      )
      ..writeln('  ${f.message}')
      ..writeln('  fix: ${f.rule.fix}')
      ..writeln();
  }
  if (seen.isNotEmpty) {
    out.writeln('Why:');
    for (final rule in seen) {
      out.writeln('  ${rule.id}: ${rule.why}');
    }
    out.writeln();
  }
  for (final file in result.untyped) {
    out.writeln(
      'note: $file was checked without type information (an import did not '
      'resolve); run `flutter pub get` for exact results.',
    );
  }
  if (result.untyped.isNotEmpty) out.writeln();
  out.writeln(_summary(result));
  return out.toString();
}

String _summary(CheckResult result) {
  String plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
  final files = plural(result.files.length, 'file');
  if (result.findings.isEmpty) return 'No findings in $files.';
  return '${plural(result.findings.length, 'finding')} '
      '(${plural(result.count(Severity.error), 'error')}, '
      '${plural(result.count(Severity.warning), 'warning')}, '
      '${result.count(Severity.info)} info) in $files.';
}

/// Machine-readable report, `"format": "tarpit-json", "formatVersion": 1`.
String jsonReport(CheckResult result) {
  final data = {
    'format': 'tarpit-json',
    'formatVersion': 1,
    'tool': {'name': 'tarpit', 'version': packageVersion},
    'files': result.files,
    'untypedFiles': result.untyped,
    'summary': {
      'error': result.count(Severity.error),
      'warning': result.count(Severity.warning),
      'info': result.count(Severity.info),
    },
    'findings': [for (final f in result.findings) f.toJson()],
  };
  return '${const JsonEncoder.withIndent('  ').convert(data)}\n';
}

/// SARIF 2.1.0 report, for GitHub code scanning and other viewers.
String sarifReport(CheckResult result) {
  String level(Severity s) => switch (s) {
    Severity.error => 'error',
    Severity.warning => 'warning',
    Severity.info => 'note',
  };
  final ruleIndex = {
    for (var i = 0; i < allRules.length; i++) allRules[i].id: i,
  };
  final data = {
    r'$schema': 'https://json.schemastore.org/sarif-2.1.0.json',
    'version': '2.1.0',
    'runs': [
      {
        'tool': {
          'driver': {
            'name': 'tarpit',
            'version': packageVersion,
            'informationUri': 'https://github.com/saimskywalker/tarpit',
            'rules': [
              for (final rule in allRules)
                {
                  'id': rule.id,
                  'name': rule.id,
                  'shortDescription': {'text': rule.title},
                  'fullDescription': {'text': rule.why},
                  'help': {'text': rule.fix},
                  'helpUri': '$_rulesDoc#${rule.id}',
                  'defaultConfiguration': {'level': level(rule.severity)},
                },
            ],
          },
        },
        'results': [
          for (final Finding f in result.findings)
            {
              'ruleId': f.rule.id,
              'ruleIndex': ruleIndex[f.rule.id],
              'level': level(f.severity),
              'message': {'text': '${f.message} Fix: ${f.rule.fix}'},
              'locations': [
                {
                  'physicalLocation': {
                    'artifactLocation': {'uri': f.path.replaceAll(r'\', '/')},
                    'region': {'startLine': f.line, 'startColumn': f.column},
                  },
                },
              ],
            },
        ],
      },
    ],
  };
  return '${const JsonEncoder.withIndent('  ').convert(data)}\n';
}

/// The rule list printed by `tarpit --rules`.
String rulesReport() {
  final out = StringBuffer();
  for (final rule in allRules) {
    out
      ..writeln('${rule.id}  (${rule.severity.name})')
      ..writeln('  ${rule.title}')
      ..writeln();
  }
  out.writeln('Details: $_rulesDoc');
  return out.toString();
}
