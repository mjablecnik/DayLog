import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/typography.dart';

enum ModuleButtonSide { left, right }

@immutable
class UiPreferences {
  const UiPreferences({
    this.moduleButtonSide = ModuleButtonSide.left,
    this.drawerEnabled = true,
    this.titleWeight = defaultTitleWeight,
    this.lastLocation,
  });

  final ModuleButtonSide moduleButtonSide;
  final bool drawerEnabled;
  final FontWeight titleWeight;
  final String? lastLocation;

  UiPreferences copyWith({
    ModuleButtonSide? moduleButtonSide,
    bool? drawerEnabled,
    FontWeight? titleWeight,
    String? lastLocation,
  }) => UiPreferences(
    moduleButtonSide: moduleButtonSide ?? this.moduleButtonSide,
    drawerEnabled: drawerEnabled ?? this.drawerEnabled,
    titleWeight: titleWeight ?? this.titleWeight,
    lastLocation: lastLocation ?? this.lastLocation,
  );
}

abstract final class UiPreferenceKeys {
  static const moduleButtonSide = 'ui_module_button_side';
  static const drawerEnabled = 'ui_drawer_enabled';
  static const titleWeight = 'ui_title_weight';
  static const lastLocation = 'ui_last_location';
}

abstract interface class UiPreferencesStore {
  Future<UiPreferences> load();
  Future<void> save(UiPreferences value);
}

class SharedPrefsUiPreferencesStore implements UiPreferencesStore {
  SharedPrefsUiPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UiPreferences> load() async {
    final weight = switch (_prefs.get(UiPreferenceKeys.titleWeight)) {
      500 => FontWeight.w500,
      700 => FontWeight.w700,
      800 => FontWeight.w800,
      _ => defaultTitleWeight,
    };
    final enabled = _prefs.get(UiPreferenceKeys.drawerEnabled);
    final location = _prefs.get(UiPreferenceKeys.lastLocation);
    return UiPreferences(
      moduleButtonSide: _prefs.get(UiPreferenceKeys.moduleButtonSide) == 'right'
          ? ModuleButtonSide.right
          : ModuleButtonSide.left,
      drawerEnabled: enabled is bool ? enabled : true,
      titleWeight: weight,
      lastLocation: location is String && location.isNotEmpty ? location : null,
    );
  }

  @override
  Future<void> save(UiPreferences value) async {
    final location = value.lastLocation;
    final results = await Future.wait([
      _prefs.setString(
        UiPreferenceKeys.moduleButtonSide,
        value.moduleButtonSide.name,
      ),
      _prefs.setBool(UiPreferenceKeys.drawerEnabled, value.drawerEnabled),
      _prefs.setInt(UiPreferenceKeys.titleWeight, value.titleWeight.value),
      if (location == null)
        _prefs.remove(UiPreferenceKeys.lastLocation)
      else
        _prefs.setString(UiPreferenceKeys.lastLocation, location),
    ]);
    if (results.contains(false)) {
      throw StateError('Unable to save device UI preferences');
    }
  }
}

final initialUiPreferencesProvider = Provider<UiPreferences>(
  (ref) => const UiPreferences(),
);

final uiPreferencesStoreProvider = Provider<UiPreferencesStore?>((ref) => null);

class UiPreferencesNotifier extends Notifier<UiPreferences> {
  Future<void> _writes = Future.value();

  @override
  UiPreferences build() => ref.read(initialUiPreferencesProvider);

  Future<void> setModuleButtonSide(ModuleButtonSide side) =>
      _update(state.copyWith(moduleButtonSide: side));

  Future<void> setDrawerEnabled(bool enabled) =>
      _update(state.copyWith(drawerEnabled: enabled));

  Future<void> setTitleWeight(FontWeight weight) =>
      _update(state.copyWith(titleWeight: weight));

  Future<void> setLastLocation(String linkName) =>
      _update(state.copyWith(lastLocation: linkName));

  Future<void> _update(UiPreferences value) {
    state = value;
    final store = ref.read(uiPreferencesStoreProvider);
    if (store == null) return Future.value();
    return _writes = _writes
        .then((_) => store.save(value))
        .catchError(
          (Object error, StackTrace stack) => FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'device UI preferences',
            ),
          ),
        );
  }
}

final uiPreferencesProvider =
    NotifierProvider<UiPreferencesNotifier, UiPreferences>(
      UiPreferencesNotifier.new,
    );
