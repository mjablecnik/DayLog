import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../providers/reminder_action_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/recurring_reminder_service.dart';
import '../../../theme/app_theme.dart';
import 'reminder_settings_screen.dart';
import '../../data/time_tracking_queries.dart';
import '../../../database/providers.dart';

/// The reminders group of the time tracking feature on the Settings page: the
/// link to the recurring reminders and, under it, the testing tools. The
/// Settings page receives this widget from the shell.
class TimeSettingsGroups extends StatelessWidget {
  const TimeSettingsGroups({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ListRow(
          title: l10n.time_settingsRecurringRemindersLabel,
          leading: const IconTile(IconAsset.bell),
          showChevron: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ReminderSettingsScreen(),
            ),
          ),
        ),
        const Divider(height: Metrics.hairline),
        ListRow(
          title: l10n.time_settingsTestingSection,
          leading: const IconTile(IconAsset.flask),
          showChevron: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TimeTestingScreen()),
          ),
        ),
      ],
    );
  }
}

/// The testing tools for notifications and the reminder dialog.
class TimeTestingScreen extends ConsumerWidget {
  const TimeTestingScreen({super.key});

  Future<void> _scheduleTestNotification(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final reminders = await db.getAllReminders();

    if (reminders.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.time_settingsNoRemindersYet),
          ),
        );
      }
      return;
    }

    final reminder = reminders.first;
    final plugin = ref.read(reminderServiceProvider).plugin;
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await plugin.zonedSchedule(
      id: 9999,
      scheduledDate: scheduledTime,
      title: l10n.time_settingsTestNotificationTitle(reminder.name),
      body: RecurringReminderService.buildNotificationBody(reminder.description, l10n),
      payload: '$recurringReminderPayloadPrefix${reminder.id}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          RecurringReminderService.channelId,
          RecurringReminderService.channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.time_settingsTestNotificationScheduled),
        ),
      );
    }
  }

  Future<void> _showReminderActionForFirst(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final reminders = await ref.read(databaseProvider).getAllReminders();
    if (reminders.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.time_settingsNoReminder)),
        );
      }
      return;
    }
    ref.read(pendingReminderActionProvider.notifier).state = reminders.first.id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.board,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(leading: HeaderLeading.back, title: l10n.time_settingsTestingSection),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  GroupedList(
                    children: [
                      ListRow(
                        leading: const IconTile(IconAsset.bell),
                        title: l10n.time_settingsTestNotificationButton,
                        onTap: () => _scheduleTestNotification(context, ref),
                      ),
                      ListRow(
                        leading: const IconTile(IconAsset.flask),
                        title: l10n.time_settingsShowModalDebugButton,
                        onTap: () => _showReminderActionForFirst(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
