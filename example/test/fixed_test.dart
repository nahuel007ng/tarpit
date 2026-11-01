// The tests from stalls_test.dart, written so they do not stall.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tarpit/flutter_test.dart';
import 'package:tarpit_example/greeting_card.dart';

void main() {
  testWidgets('waits for the name by pumping', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GreetingCard(
          loadName: () =>
              Future.delayed(const Duration(milliseconds: 100), () => 'Ada'),
        ),
      ),
    );
    // Fake time: fires the 100 ms timer without waiting for it.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Hello, Ada'), findsOneWidget);
  });

  testWidgets('reads the name from a file', (tester) async {
    final name = await tester.runAsync(
      () => File('test/name.txt').readAsString(),
    );
    await tester.pumpWidget(
      MaterialApp(home: GreetingCard(loadName: () async => name!.trim())),
    );
    await tester.pump();
    expect(find.text('Hello, Ada'), findsOneWidget);
  });

  testWidgets('shows the spinner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CircularProgressIndicator())),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
