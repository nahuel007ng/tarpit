// These tests stall on purpose. `dart run tarpit` points at each line, and
// `flutter test test/stalls_test.dart` fails them after a few seconds
// instead of hanging, because this file imports package:tarpit/flutter_test.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tarpit/flutter_test.dart';
import 'package:tarpit_example/greeting_card.dart';

void main() {
  Tarpit.stallAfter = const Duration(seconds: 3);

  testWidgets('waits for the name with a delay', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GreetingCard(
          loadName: () =>
              Future.delayed(const Duration(milliseconds: 100), () => 'Ada'),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('Hello, Ada'), findsOneWidget);
  });

  testWidgets('reads the name from a file', (tester) async {
    final name = await File('test/name.txt').readAsString();
    await tester.pumpWidget(
      MaterialApp(home: GreetingCard(loadName: () async => name.trim())),
    );
    await tester.pump();
    expect(find.text('Hello, Ada'), findsOneWidget);
  });

  testWidgets('settles while the spinner is up', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CircularProgressIndicator())),
    );
    await tester.pumpAndSettle();
  });
}
