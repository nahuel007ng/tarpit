// dart format off
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late File fixture;

  setUpAll(() async {
    // Outside testWidgets there is no FakeAsync zone.
    fixture = File('${(await Directory.systemTemp.createTemp()).path}/a.txt');
    await fixture.writeAsString('hello');
  });

  testWidgets('reads a file', (tester) async {
    final text = await fixture.readAsString(); // expect: real-io error
    expect(text, 'hello');
    await File('b.txt').exists(); // expect: real-io error
    final dir = await Directory.systemTemp.createTemp(); // expect: real-io error
    await Process.run('true', []); // expect: real-io error
    await Socket.connect('localhost', 1).timeout(const Duration(seconds: 1)); // expect: real-io error
    dir.deleteSync();
  });

  testWidgets('safe uses', (tester) async {
    final text = await tester.runAsync(() => fixture.readAsString());
    expect(text, 'hello');
    await tester.runAsync(() async {
      await fixture.exists();
    });
    // Synchronous I/O does not wait on the event loop.
    expect(fixture.readAsStringSync(), 'hello');
    // flutter_test replaces HttpClient with a fake that answers 400 at once.
    final request = await HttpClient().getUrl(Uri.parse('http://example.invalid/'));
    await request.close();
  });

  testWidgets('I/O in a callback', (tester) async {
    Future<void> save() async {
      await fixture.writeAsString('x'); // expect: real-io info
    }

    expect(save, isNotNull);
  });
}
