/// The static checker behind the `tarpit` command, for use from Dart code.
///
/// This library does not import Flutter.
library;

export 'src/checker/checker.dart'
    show CheckResult, Checker, CheckerInputException, checkUnit;
export 'src/checker/cli.dart' show exitClean, exitFindings, exitUsage, runCli;
export 'src/checker/finding.dart' show Finding;
export 'src/checker/report.dart'
    show jsonReport, rulesReport, sarifReport, textReport;
export 'src/checker/rules.dart'
    show
        Rule,
        Severity,
        allRules,
        assetString,
        badSuppression,
        blockingSleep,
        endlessSettle,
        engineAsync,
        fakeDelay,
        isolateHop,
        realIo,
        ruleById;
export 'src/checker/version.dart' show packageVersion;
