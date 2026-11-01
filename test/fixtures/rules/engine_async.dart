// dart format off
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waits on the engine', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const Placeholder()));
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(); // expect: engine-async error
    await image.toByteData(format: ui.ImageByteFormat.png); // expect: engine-async error
    final recorder = ui.PictureRecorder();
    await recorder.endRecording().toImage(1, 1); // expect: engine-async error
    final codec = await ui.instantiateImageCodec(Uint8List(0));
    await codec.getNextFrame(); // expect: engine-async error
    await precacheImage(MemoryImage(Uint8List(0)), key.currentContext!); // expect: engine-async error
  });

  testWidgets('safe uses', (tester) async {
    final recorder = ui.PictureRecorder();
    final image = recorder.endRecording().toImageSync(1, 1);
    await tester.runAsync(() => image.toByteData());
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(Uint8List(0));
      await codec.getNextFrame();
    });
  });
}
