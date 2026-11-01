import 'dart:io';

import 'package:tarpit/checker.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runCli(arguments);
}
