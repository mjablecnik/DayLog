import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zafling/database/import/preferences_writer.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('writes every type with its own setter', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int written = await writePreferences(prefs, <String, Object?>{
      'a_string': 'x',
      'a_bool': true,
      'an_int': 7,
      'a_double': 0.5,
      'a_list': <Object?>['one', 'two'],
      'a_null': null,
    });
    expect(written, 5);
    expect(prefs.getString('a_string'), 'x');
    expect(prefs.getBool('a_bool'), true);
    expect(prefs.getInt('an_int'), 7);
    expect(prefs.getDouble('a_double'), 0.5);
    expect(prefs.getStringList('a_list'), <String>['one', 'two']);
    expect(prefs.containsKey('a_null'), isFalse);
  });

  // Feature: legacy-import, Property 6: Ignored preferences
  test('writes every key except the ignored ones and the timer state', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Random random = Random(6);
    for (int round = 0; round < 25; round++) {
      final Map<String, Object?> values = <String, Object?>{
        for (int i = 0; i < 8; i++) 'key_${random.nextInt(30)}': random.nextInt(100),
        for (final String key in ignoredPreferenceKeys) key: 'x',
        'timer_endAt': 'y',
        'timer_anything_${random.nextInt(5)}': 'z',
      };
      await prefs.clear();
      await writePreferences(prefs, values);
      for (final String key in values.keys) {
        expect(prefs.containsKey(key), isImportedPreference(key), reason: key);
      }
    }
    expect(isImportedPreference('app_language'), isFalse);
    expect(isImportedPreference('selected_theme'), isFalse);
    expect(isImportedPreference('timer_status'), isFalse);
    expect(isImportedPreference('reminder_enabled'), isTrue);
  });
}
