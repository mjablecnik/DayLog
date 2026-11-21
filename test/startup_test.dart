import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/startup.dart';

import 'helpers/test_database.dart';

void main() {
  // The startup waits for the app settings the way the real time tracking
  // startup does. A wait that never ends (a provider nobody listens to is
  // paused in Riverpod 3) leaves the app on an empty screen, so the startup
  // gets a time limit. Rendering the app is covered by the shell tests.
  test('the startup waits for the settings, finishes and returns the app', () async {
    final db = createTestDatabase();
    final dir = Directory.systemTemp.createTempSync('daylog_startup');
    var settingsWereReady = false;

    final app = await buildApp(
      database: db,
      documentsDirectory: dir,
      deepLinks: const Stream<Uri>.empty(),
      startTimeTracking: (container, settingsReady) async {
        await settingsReady();
        settingsWereReady = true;
      },
    ).timeout(const Duration(seconds: 10));

    expect(settingsWereReady, isTrue);
    expect(app, isA<UncontrolledProviderScope>());
    (app as UncontrolledProviderScope).container.dispose();
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
