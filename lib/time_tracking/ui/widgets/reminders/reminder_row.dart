import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/recurring_reminders_provider.dart';
import '../../../domain/active_days_utils.dart';
import '../../../services/recurring_reminder_service.dart' show isoDateString;
import '../../../data/time_tracking_queries.dart';
import '../../../../database/providers.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/controls/check_circle.dart';
import '../../../../ui_kit/layout/swipe_actions.dart';

/// A single Recurring_Reminder entry: time window, interval, active days,
/// today's completion checkbox, active/inactive toggle, and edit/delete
/// actions (Requirements 1.2, 1.3, 1.4, 1.5, 3.1, 12.1).
class ReminderRow extends ConsumerStatefulWidget {
  final RecurringReminder reminder;
  final AppThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderRow({
    super.key,
    required this.reminder,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends ConsumerState<ReminderRow> {
  bool _completedToday = false;
  bool _loadingCompletion = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompletion();
  }

  @override
  void didUpdateWidget(covariant ReminderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.id != widget.reminder.id) {
      _loadCompletion();
    }
  }

  Future<void> _loadCompletion() async {
    final db = ref.read(databaseProvider);
    final today = isoDateString(tz.TZDateTime.now(tz.local));
    final has = await db.hasCompletionForToday(widget.reminder.id, today);
    if (mounted) {
      setState(() {
        _completedToday = has;
        _loadingCompletion = false;
      });
    }
  }

  String _formatTime(int minutesFromMidnight) {
    final h = (minutesFromMidnight ~/ 60).toString().padLeft(2, '0');
    final m = (minutesFromMidnight % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatActiveDays(AppLocalizations l10n, int mask) {
    final labels = weekdayShortLabels(l10n);
    final days = decodeDays(mask);
    return List.generate(
      7,
      (i) => i + 1,
    ).where(days.contains).map((day) => labels[day - 1]).join(', ');
  }

  Future<void> _toggleCompletion(bool? checked) async {
    setState(() => _error = null);
    final notifier = ref.read(recurringRemindersProvider.notifier);
    try {
      if (checked == true) {
        await notifier.markDoneForToday(widget.reminder.id);
      } else {
        await notifier.undoCompletionForToday(widget.reminder.id);
      }
      await _loadCompletion();
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = AppLocalizations.of(context)
                  .time_reminderCompletionUpdateFailed,
        );
      }
    }
  }

  Future<void> _toggleActive(bool _) async {
    setState(() => _error = null);
    try {
      await ref
          .read(recurringRemindersProvider.notifier)
          .toggleActive(widget.reminder.id);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (e is InsufficientNotificationCapacityError) {
        setState(
          () =>
              _error = l10n.time_reminderCapacityError(e.available, e.required),
        );
      } else {
        setState(() => _error = l10n.time_reminderActiveToggleFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final strings = AppLocalizations.of(context);
    final palette = context.palette;
    final body = context.bodyText;
    final window = strings.time_reminderWindow(
      _formatTime(reminder.startTime),
      _formatTime(reminder.endTime),
      reminder.repeatInterval,
    );
    return SwipeActions(
      groupTag: 'reminders',
      actions: [
        SwipeActionSpec.delete(
          context,
          key: ValueKey('reminder-delete-${reminder.id}'),
          onPressed: widget.onDelete,
        ),
      ],
      child: Opacity(
        opacity: reminder.isActive ? 1 : 0.5,
        child: InkWell(
          onTap: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s8,
              vertical: Space.s8,
            ),
            child: Row(
              children: [
                CheckCircle(
                  checked: _completedToday,
                  semanticLabel:
                      '${reminder.name}, ${strings.time_reminderDone}',
                  onTap: _loadingCompletion
                      ? null
                      : () => _toggleCompletion(!_completedToday),
                ),
                const SizedBox(width: Space.s6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.name,
                        style: body.titleMedium?.copyWith(
                          fontSize: 16.5,
                          decoration: _completedToday
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        window,
                        style: body.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: palette.textDim,
                        ),
                      ),
                      Text(
                        _formatActiveDays(strings, reminder.activeDays),
                        style: body.bodySmall?.copyWith(
                          fontSize: 13,
                          color: palette.textFaint,
                        ),
                      ),
                      if (_error case final error?)
                        Text(
                          error,
                          style: body.bodySmall?.copyWith(
                            color: palette.destructiveText,
                          ),
                        ),
                    ],
                  ),
                ),
                Semantics(
                  label: strings.time_reminderActiveLabel,
                  child: Switch(
                    value: reminder.isActive,
                    onChanged: _toggleActive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
