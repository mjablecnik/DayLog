import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/common/empty_state.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/layout/header_action.dart';
import '../../../ui_kit/sheet/confirm_destructive.dart';

import '../../theme/time_theme.dart';
import '../../../database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/recurring_reminders_provider.dart';
import '../widgets/reminders/reminder_row.dart';
import '../widgets/reminders/reminder_sheet.dart';

/// Reminder list sub-screen within Settings: create, edit, delete, and
/// toggle Recurring_Reminders (Requirement 1).
class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  void _addReminder(BuildContext context, AppThemeData theme) {
    showReminderSheet(context, theme: theme);
  }

  void _editReminder(
    BuildContext context,
    AppThemeData theme,
    RecurringReminder reminder,
  ) {
    showReminderSheet(context, theme: theme, reminder: reminder);
  }

  Future<void> _deleteReminder(
    BuildContext context,
    WidgetRef ref,
    RecurringReminder reminder,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.time_reminderDeleteTitle,
      body: l10n.time_reminderDeleteBody(reminder.name),
      confirmLabel: l10n.time_commonDelete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref
          .read(recurringRemindersProvider.notifier)
          .deleteReminder(reminder.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.time_reminderDeleteFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    final remindersAsync = ref.watch(recurringRemindersProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              title: l10n.time_settingsRecurringRemindersLabel,
              leading: HeaderLeading.back,
              trailing: [
                HeaderAction(
                  icon: IconAsset.plus,
                  semanticLabel: l10n.time_reminderNewTitle,
                  onPressed: () => _addReminder(context, theme),
                ),
              ],
            ),
            Expanded(
              child: remindersAsync.when(
                data: (reminders) {
                  if (reminders.isEmpty) {
                    return EmptyState(
                      title: l10n.time_remindersEmptyTitle,
                      body: l10n.time_remindersEmptySubtitle,
                      icon: IconAsset.bell,
                    );
                  }
                  return SlidableAutoCloseBehavior(
                    child: ListView(
                      padding: const EdgeInsets.all(Space.s16),
                      children: [
                        GroupedList(
                          children: [
                            for (final reminder in reminders)
                              ReminderRow(
                                key: ValueKey(reminder.id),
                                reminder: reminder,
                                theme: theme,
                                onEdit: () =>
                                    _editReminder(context, theme, reminder),
                                onDelete: () =>
                                    _deleteReminder(context, ref, reminder),
                              ),
                          ],
                        ),
                        const SizedBox(height: Space.s12),
                        Text(
                          l10n.time_reminderSwipeHint,
                          textAlign: TextAlign.center,
                          style: context.bodyText.bodySmall?.copyWith(
                            color: context.palette.textFaint,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: theme.accent),
                ),
                error: (error, _) => Center(
                  child: Text(
                    l10n.time_remindersLoadFailed,
                    style: TextStyle(color: theme.dim),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
