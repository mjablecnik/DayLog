import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs for every test file.
///
/// - The app keeps some state in SharedPreferences (the timer, the reminders),
///   which has no platform side in a test, so every file starts with an empty
///   in-memory store. A test that needs other values calls
///   `SharedPreferences.setMockInitialValues` itself.
/// - The bundled font Figtree is registered: the test engine draws every other
///   family in square glyphs about twice as wide as the real ones, which would
///   report overflows that cannot happen on a device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final FontLoader figtree = FontLoader('Figtree');
  for (final int weight in <int>[400, 500, 600, 700, 800]) {
    final Uint8List bytes = File('assets/fonts/Figtree-$weight.ttf').readAsBytesSync();
    figtree.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await figtree.load();
  await testMain();
}
