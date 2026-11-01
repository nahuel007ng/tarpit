import 'rules.dart';

/// One reported problem at a location in a test file.
class Finding implements Comparable<Finding> {
  /// Creates a finding.
  const Finding({
    required this.rule,
    required this.severity,
    required this.path,
    required this.line,
    required this.column,
    required this.message,
  });

  /// The rule that produced it.
  final Rule rule;

  /// Severity of this occurrence; can be lower than the rule's default.
  final Severity severity;

  /// Path of the file, relative to the working directory when possible.
  final String path;

  /// 1-based line.
  final int line;

  /// 1-based column.
  final int column;

  /// What was found, specific to this occurrence.
  final String message;

  /// The finding as a JSON-compatible map.
  Map<String, Object> toJson() => {
    'rule': rule.id,
    'severity': severity.name,
    'path': path,
    'line': line,
    'column': column,
    'message': message,
    'why': rule.why,
    'fix': rule.fix,
  };

  @override
  int compareTo(Finding other) {
    final byPath = path.compareTo(other.path);
    if (byPath != 0) return byPath;
    final byLine = line.compareTo(other.line);
    if (byLine != 0) return byLine;
    final byColumn = column.compareTo(other.column);
    if (byColumn != 0) return byColumn;
    return rule.id.compareTo(other.rule.id);
  }

  @override
  String toString() =>
      '$path:$line:$column ${severity.name} ${rule.id}: $message';
}
