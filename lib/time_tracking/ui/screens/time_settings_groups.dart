import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/common/settings_group.dart';
import '../../../ui_kit/common/settings_nav_row.dart';
import '../../../ui_kit/common/sub_page_header.dart';
import '../../providers/reminder_action_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/recurring_reminder_service.dart';
import '../../theme/time_theme.dart';
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
    return SettingsGroup(
      label: l10n.time_settingsRemindersSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsNavRow(
            title: l10n.time_settingsRecurringRemindersLabel,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ReminderSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SettingsNavRow(
            title: l10n.time_settingsTestingSection,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TimeTestingScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A rounded panel in the colours of the time tracking theme.
class _Panel extends StatelessWidget {
  const _Panel({required this.theme, required this.child});

  final AppThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: child,
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppThemeData theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      theme: theme,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: theme.dim, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: theme.text, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
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
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubPageHeader(title: l10n.time_settingsTestingSection),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  _ToolRow(
                    theme: theme,
                    icon: Icons.bug_report,
                    label: l10n.time_settingsTestNotificationButton,
                    onTap: () => _scheduleTestNotification(context, ref),
                  ),
                  const SizedBox(height: 8),
                  _ToolRow(
                    theme: theme,
                    icon: Icons.open_in_new,
                    label: l10n.time_settingsShowModalDebugButton,
                    onTap: () => _showReminderActionForFirst(context, ref),
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
