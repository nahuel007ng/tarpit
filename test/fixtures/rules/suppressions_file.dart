// dart format off
// tarpit:allow-file engine-async this file runs only with a real engine binding
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('whole file allowed', (tester) async {
    final image = ui.PictureRecorder().endRecording().toImageSync(1, 1);
    await image.toByteData();
  });
}
