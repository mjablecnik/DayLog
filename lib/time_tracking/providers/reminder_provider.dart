import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/reminder_service.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

/// Preference keys of the daily reminder that earlier versions stored.
const List<String> _legacyDailyReminderKeys = <String>[
  'reminder_enabled',
  'reminder_hour',
  'reminder_minute',
];

/// Removes what the daily "start the timer" reminder left behind: the
/// scheduled notification and its preferences (an old export can bring them
/// back, too).
Future<void> removeLegacyDailyReminder(ReminderService service) async {
  await service.cancelLegacyDailyReminder();
  final prefs = await SharedPreferences.getInstance();
  for (final key in _legacyDailyReminderKeys) {
    await prefs.remove(key);
  }
}
