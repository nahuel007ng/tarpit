import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

import 'rules.dart';

/// The comment marker. `// tarpit:allow <rule-id>[,<rule-id>] <reason>`
/// silences a finding on its own line, or on the next line when the comment
/// stands alone. `// tarpit:allow-file ...` silences the rules in the whole
/// file.
final _marker = RegExp(r'^//\s*tarpit:(allow-file|allow)\b(.*)$');

/// A malformed suppression comment, reported as `bad-suppression`.
class BadSuppression {
  /// Creates a report for a malformed suppression.
  const BadSuppression(this.offset, this.message);

  /// Offset of the comment.
  final int offset;

  /// What is wrong with it.
  final String message;
}

/// The valid suppressions in one file.
class Suppressions {
  Suppressions._(this._byLine, this._fileWide, this.problems);

  /// Reads the `tarpit:allow` comments of [unit]; [source] is its text.
  factory Suppressions.of(CompilationUnit unit, String source) {
    final byLine = <int, Set<String>>{};
    final fileWide = <String>{};
    final problems = <BadSuppression>[];
    final lineInfo = unit.lineInfo;

    for (final comment in _comments(unit)) {
      final match = _marker.firstMatch(comment.lexeme);
      if (match == null) continue;
      final fileLevel = match.group(1) == 'allow-file';
      final rest = match.group(2)!.trim();
      final space = rest.indexOf(RegExp(r'\s'));
      final idList = space < 0 ? rest : rest.substring(0, space);
      final reason = space < 0 ? '' : rest.substring(space).trim();

      final ids = idList.split(',').where((id) => id.isNotEmpty).toList();
      if (ids.isEmpty) {
        problems.add(
          BadSuppression(
            comment.offset,
            'The tarpit:allow comment names no rule; it is ignored.',
          ),
        );
        continue;
      }
      final unknown = [
        for (final id in ids)
          if (ruleById(id) == null || id == badSuppression.id) id,
      ];
      if (unknown.isNotEmpty) {
        problems.add(
          BadSuppression(
            comment.offset,
            'Unknown rule id ${unknown.map((id) => '"$id"').join(', ')} in '
            'tarpit:allow; the comment is ignored. Run `tarpit --rules` for '
            'the list.',
          ),
        );
        continue;
      }
      if (reason.isEmpty) {
        problems.add(
          BadSuppression(
            comment.offset,
            'The tarpit:allow comment for ${ids.join(', ')} gives no reason; '
            'it is ignored. Say why the pattern cannot stall here.',
          ),
        );
        continue;
      }

      if (fileLevel) {
        fileWide.addAll(ids);
        continue;
      }
      final location = lineInfo.getLocation(comment.offset);
      final lineStart = lineInfo.getOffsetOfLine(location.lineNumber - 1);
      final before = source.substring(lineStart, comment.offset);
      final standsAlone = before.trim().isEmpty;
      final line = standsAlone ? location.lineNumber + 1 : location.lineNumber;
      byLine.putIfAbsent(line, () => <String>{}).addAll(ids);
    }
    return Suppressions._(byLine, fileWide, problems);
  }

  final Map<int, Set<String>> _byLine;
  final Set<String> _fileWide;

  /// Malformed comments found while reading.
  final List<BadSuppression> problems;

  /// Whether [ruleId] is silenced on 1-based [line].
  bool covers(String ruleId, int line) =>
      _fileWide.contains(ruleId) || (_byLine[line]?.contains(ruleId) ?? false);
}

Iterable<Token> _comments(CompilationUnit unit) sync* {
  Token? token = unit.beginToken;
  while (token != null) {
    Token? comment = token.precedingComments;
    while (comment != null) {
      yield comment;
      comment = comment.next;
    }
    if (token.type == TokenType.EOF) break;
    token = token.next;
  }
}
