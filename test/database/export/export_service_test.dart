import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zafling/database/app_database.dart';
import 'package:zafling/database/export/database_export.dart';
import 'package:zafling/database/export/export_service.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  test('the export file carries the SharedPreferences, sorted by key, and a dated name', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'reminder_hour': 8,
      'app_language': 'cs',
      'reminder_enabled': true,
      'known_names': <String>['Zafling'],
    });
    final AppDatabase db = createTestDatabase();
    addTearDown(db.close);
    final ExportService service = ExportService(db, FixedClock(DateTime(2026, 11, 20, 9)), () async => '1.0.0');

    final export = await service.build();

    expect(export.fileName, 'zafling-export-2026-11-20.json');
    final Map<String, Object?> data = jsonDecode(export.json) as Map<String, Object?>;
    expect(data['format'], exportFormat);
    expect(data['app'], 'zafling');
    expect(data['appVersion'], '1.0.0');
    final Map<String, Object?> prefs = data['preferences']! as Map<String, Object?>;
    expect(prefs.keys.toList(), <String>['app_language', 'known_names', 'reminder_enabled', 'reminder_hour']);
    expect(prefs['reminder_hour'], 8);
    expect(prefs['reminder_enabled'], true);
    expect(prefs['known_names'], <Object?>['Zafling']);
  });
}
