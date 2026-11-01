// dart format off
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('spinner then settle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: CircularProgressIndicator())));
    await tester.pumpAndSettle(); // expect: endless-settle warning
  });

  testWidgets('cupertino spinner, settle later', (tester) async {
    await tester.pumpWidget(const CupertinoApp(home: CupertinoActivityIndicator()));
    await tester.tap(find.byType(CupertinoActivityIndicator));
    await tester.pumpAndSettle(); // expect: endless-settle info
  });

  testWidgets('safe uses', (tester) async {
    // A determinate indicator stops animating.
    await tester.pumpWidget(const MaterialApp(home: LinearProgressIndicator(value: 0.5)));
    await tester.pumpAndSettle();
    // A stopped Cupertino indicator does not animate.
    await tester.pumpWidget(const CupertinoApp(home: CupertinoActivityIndicator(animating: false)));
    await tester.pumpAndSettle();
    // Spinner shown only while loading: depends on state, not reported.
    await tester.pumpWidget(
      MaterialApp(
        home: FutureBuilder<int>(
          future: Future<int>.value(1),
          builder: (context, snapshot) =>
              snapshot.hasData ? const Text('done') : const CircularProgressIndicator(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Pumping a fixed duration is fine with a spinner on screen.
    await tester.pumpWidget(const MaterialApp(home: CircularProgressIndicator()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const MaterialApp(home: Text('done')));
    await tester.pumpAndSettle();
  });
}
