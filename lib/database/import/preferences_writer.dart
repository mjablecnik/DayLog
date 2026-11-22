import 'package:shared_preferences/shared_preferences.dart';

/// Preference keys the importer never writes: the language and theme live in
/// the app settings, and a pending reminder tap or a running timer of another
/// install means nothing here.
const Set<String> ignoredPreferenceKeys = <String>{
  'app_language',
  'selected_theme',
  'pending_reminder_action_id',
  'handled_launch_reminder_id',
  'last_task_project_id',
};

/// Key prefix of the persisted timer state, which is never imported.
const String ignoredPreferencePrefix = 'timer_';

bool isImportedPreference(String key) =>
    !ignoredPreferenceKeys.contains(key) &&
    !key.startsWith(ignoredPreferencePrefix) &&
    !key.startsWith('ui_');

/// Writes [values] into [prefs] with their types (string, int, double, bool,
/// list of strings), skipping the keys the importer ignores. Returns how many
/// were written.
Future<int> writePreferences(SharedPreferences prefs, Map<String, Object?> values) async {
  int written = 0;
  for (final MapEntry<String, Object?> entry in values.entries) {
    if (!isImportedPreference(entry.key)) continue;
    final Object? value = entry.value;
    switch (value) {
      case final String v:
        await prefs.setString(entry.key, v);
      case final bool v:
        await prefs.setBool(entry.key, v);
      case final int v:
        await prefs.setInt(entry.key, v);
      case final double v:
        await prefs.setDouble(entry.key, v);
      case final List<Object?> v:
        await prefs.setStringList(entry.key, <String>[for (final Object? item in v) '$item']);
      default:
        continue;
    }
    written++;
  }
  return written;
}
