import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/recurring_reminders_provider.dart';
import 'providers/reminder_action_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/timer_provider.dart';
import 'services/recurring_reminder_service.dart';

/// SharedPreferences key that carries the id of a tapped reminder across a
/// suspension: the Dart callback may fire while the widget tree is suspended on
/// iOS, so the host reads it again on resume.
const String kPendingReminderIdKey = 'pending_reminder_action_id';

/// SharedPreferences key of the last launch reminder that was already handled:
/// iOS reports the same launch details until the app is fully relaunched.
const String _kHandledLaunchReminderIdKey = 'handled_launch_reminder_id';

/// Starts everything the time tracking feature needs before the first frame:
/// the notification permission, the reminder plugin, a reminder tap that
/// launched the app, and the reminder schedules.
class TimeTrackingBootstrap {
  TimeTrackingBootstrap(this._container);

  final ProviderContainer _container;

  /// Brings the feature in line with preferences an import has just written:
  /// the daily reminder an old export may bring back is removed and the
  /// recurring reminders are re-scheduled.
  Future<void> refreshAfterImport() async {
    await removeLegacyDailyReminder(_container.read(reminderServiceProvider));
    await _container.read(recurringReminderServiceProvider).rescheduleAll();
  }

  /// Runs the startup. [settingsReady] completes once the app settings (the
  /// language the notification texts use) are loaded.
  Future<void> start({required Future<void> Function() settingsReady}) async {
    _container.read(notificationServiceProvider).requestPermission();

    final reminderService = _container.read(reminderServiceProvider);

    await reminderService.initialize(
      onNotificationTap: (payload) {
        final reminderId = parseReminderIdFromPayload(payload);
        if (reminderId != null) {
          // Persisted so the value survives a suspended Dart isolate; the host
          // reads it on resume. The provider covers the foreground case.
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt(kPendingReminderIdKey, reminderId);
          });
          _container.read(pendingReminderActionProvider.notifier).state = reminderId;
        }
      },
    );

    // A tap persisted by an earlier run (the app was killed after the tap, or
    // this is a cold launch).
    final prefs = await SharedPreferences.getInstance();
    final persistedReminderId = prefs.getInt(kPendingReminderIdKey);
    if (persistedReminderId != null) {
      _container.read(pendingReminderActionProvider.notifier).state = persistedReminderId;
      await prefs.remove(kPendingReminderIdKey);
    }

    final launchPayload = await reminderService.getLaunchPayload();
    final launchReminderId = parseReminderIdFromPayload(launchPayload);
    if (launchReminderId != null) {
      // Only once: iOS returns the same launch details on every call until
      // the app is relaunched with a different intent.
      final lastHandled = prefs.getInt(_kHandledLaunchReminderIdKey);
      if (lastHandled != launchReminderId) {
        await prefs.setInt(_kHandledLaunchReminderIdKey, launchReminderId);
        _container.read(pendingReminderActionProvider.notifier).state = launchReminderId;
      }
    }
  

    await settingsReady();
    await removeLegacyDailyReminder(reminderService);
    await _container.read(recurringReminderServiceProvider).rescheduleAll();
  }
}
