import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/recurring_reminders_provider.dart';
import '../../../domain/active_days_utils.dart';
import '../controls/day_selector.dart';
import 'reminder_form_data.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_segmented.dart';
import '../../../../ui_kit/forms/form_field_box.dart';
import '../../../../ui_kit/layout/section_headers.dart';
import '../../../../ui_kit/sheet/app_sheet.dart';

/// Opens the reminder form and confirms before discarding unsaved changes.
Future<void> showReminderSheet(
  BuildContext context, {
  required AppThemeData theme,
  RecurringReminder? reminder,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => ReminderSheet(theme: theme, reminder: reminder),
  );
}

/// Create/edit modal for a Recurring_Reminder (Requirement 2). Pass
/// [reminder] to pre-fill for editing; omit it to create a new reminder with
/// the spec's default values (08:00–00:00, 60 min, all days, active).
class ReminderSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final RecurringReminder? reminder;

  const ReminderSheet({super.key, required this.theme, this.reminder});

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  static const _intervals = [30, 60, 120, 180, 240];

  late final TextEditingController _nameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _repeatInterval;
  late Set<int> _activeDays;
  late bool _isActive;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    if (reminder == null) {
      _nameController = TextEditingController();
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 0, minute: 0);
      _repeatInterval = 60;
      _activeDays = {1, 2, 3, 4, 5, 6, 7};
      _isActive = true;
    } else {
      _nameController = TextEditingController(text: reminder.name);
      _startTime = _fromMinutes(reminder.startTime);
      _endTime = _fromMinutes(reminder.endTime);
      _repeatInterval = reminder.repeatInterval;
      _activeDays = decodeDays(reminder.activeDays);
      _isActive = reminder.isActive;
    }
  }

  static TimeOfDay _fromMinutes(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ReminderFormData get _formData => ReminderFormData(
    name: _nameController.text,
    startTime: _startTime,
    endTime: _endTime,
    repeatIntervalMinutes: _repeatInterval,
    activeDays: _activeDays,
    isActive: _isActive,
  );

  bool get _isOvernight =>
      _startTime.hour * 60 + _startTime.minute >=
      _endTime.hour * 60 + _endTime.minute;

  bool get _hasUnsavedChanges {
    final reminder = widget.reminder;
    if (reminder == null) {
      return _nameController.text.trim().isNotEmpty ||
          _startTime != const TimeOfDay(hour: 8, minute: 0) ||
          _endTime != const TimeOfDay(hour: 0, minute: 0) ||
          _repeatInterval != 60 ||
          !_setEquals(_activeDays, {1, 2, 3, 4, 5, 6, 7}) ||
          !_isActive;
    }
    return _nameController.text != reminder.name ||
        _startTime != _fromMinutes(reminder.startTime) ||
        _endTime != _fromMinutes(reminder.endTime) ||
        _repeatInterval != reminder.repeatInterval ||
        !_setEquals(_activeDays, decodeDays(reminder.activeDays)) ||
        _isActive != reminder.isActive;
  }

  static bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.every(b.contains);

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    final data = _formData;
    if (!data.isValid || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final notifier = ref.read(recurringRemindersProvider.notifier);
      final reminder = widget.reminder;
      if (reminder == null) {
        await notifier.addReminder(data.toCompanion());
      } else {
        await notifier.updateReminder(reminder.id, data.toCompanion());
      }
      if (mounted) AppSheet.close(context);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = e is InsufficientNotificationCapacityError
            ? l10n.time_reminderCapacityError(e.available, e.required)
            : l10n.time_errorGeneric;
        _saving = false;
      });
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);
    final data = _formData;

    return AppSheet(
      title: _isEditing
          ? l10n.time_reminderEditTitle
          : l10n.time_reminderNewTitle,
      primaryLabel: l10n.time_commonSave,
      primaryEnabled: data.isValid && !_saving,
      isDirty: _hasUnsavedChanges,
      discardCopy: (
        title: l10n.time_reminderDiscardTitle,
        body: l10n.time_reminderDiscardBody,
        confirm: l10n.time_reminderDiscardConfirm,
        cancel: l10n.time_commonBack,
      ),
      onPrimary: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: l10n.time_reminderNameHint,
              counterText: '${_nameController.text.characters.length} / 100',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Space.s12),
          Row(
            children: [
              Expanded(
                child: FormFieldBox(
                  label: l10n.time_reminderFromLabel,
                  value: _formatTime(_startTime),
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: Space.s12),
              Expanded(
                child: FormFieldBox(
                  label: l10n.time_reminderToLabel,
                  value: _formatTime(_endTime),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          if (_isOvernight) ...[
            const SizedBox(height: Space.s8),
            Text(
              l10n.time_reminderOvernightNote,
              style: context.bodyText.bodySmall?.copyWith(color: theme.accent),
            ),
          ],
          const SizedBox(height: Space.s16),
          SectionLabel(l10n.time_reminderIntervalLabel),
          const SizedBox(height: Space.s8),
          AppSegmented<int>(
            options: [
              for (final minutes in _intervals)
                SegmentedOption(value: minutes, label: '$minutes'),
            ],
            selected: _repeatInterval,
            onChanged: (minutes) => setState(() => _repeatInterval = minutes),
          ),
          const SizedBox(height: Space.s4),
          Text(
            l10n.time_reminderMinutesUnit,
            style: context.bodyText.bodySmall?.copyWith(
              color: context.palette.textDim,
            ),
          ),
          const SizedBox(height: Space.s16),
          SectionLabel(l10n.time_reminderActiveDaysLabel),
          const SizedBox(height: Space.s8),
          DaySelector(
            activeDays: _activeDays,
            theme: theme,
            onChanged: (days) => setState(() => _activeDays = days),
          ),
          const SizedBox(height: Space.s16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.time_reminderActiveLabel),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          if (_error case final error?)
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: context.bodyText.bodySmall?.copyWith(
                  color: context.palette.destructiveText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
