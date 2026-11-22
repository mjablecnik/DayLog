import 'package:daylog/core/ui_preferences.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('round-trips the experiment settings and last location', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPrefsUiPreferencesStore(prefs);
    for (final side in ModuleButtonSide.values) {
      for (final enabled in [true, false]) {
        for (final weight in [
          FontWeight.w500,
          FontWeight.w600,
          FontWeight.w700,
          FontWeight.w800,
        ]) {
          await store.save(
            UiPreferences(
              moduleButtonSide: side,
              drawerEnabled: enabled,
              titleWeight: weight,
              lastLocation: 'missions',
            ),
          );
          final loaded = await store.load();
          expect(loaded.moduleButtonSide, side);
          expect(loaded.drawerEnabled, enabled);
          expect(loaded.titleWeight, weight);
          expect(loaded.lastLocation, 'missions');
        }
      }
    }
  });

  test('falls back when stored values have the wrong type or value', () async {
    SharedPreferences.setMockInitialValues({
      UiPreferenceKeys.moduleButtonSide: 'centre',
      UiPreferenceKeys.drawerEnabled: 'false',
      UiPreferenceKeys.titleWeight: 901,
      UiPreferenceKeys.lastLocation: 8,
    });
    final store = SharedPrefsUiPreferencesStore(
      await SharedPreferences.getInstance(),
    );
    final loaded = await store.load();
    expect(loaded.moduleButtonSide, ModuleButtonSide.left);
    expect(loaded.drawerEnabled, isTrue);
    expect(loaded.titleWeight, FontWeight.w600);
    expect(loaded.lastLocation, isNull);
  });
}
