import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../ui_kit/forms/app_text_field.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/layout/header_action.dart';
import '../../../../ui_kit/sheet/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/activity_types.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/database_service.dart'
    show OverlappingEntryException;
import '../../../providers/suggestions_provider.dart';
import '../../../providers/history_provider.dart' show logicalDay;
import '../activity_picker/activity_picker.dart';
import 'entry_time_fields.dart';

class ManualEntrySheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime selectedDay;

  const ManualEntrySheet({
    super.key,
    required this.theme,
    required this.selectedDay,
  });

  @override
  ConsumerState<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<ManualEntrySheet> {
  final _controller = TextEditingController();
  // New manual entries start with the first type; the subtype is restored by
  // the picker from the last one used for that type.
  final _initialSelection = ActivitySelection(typeKey: activityTypes.first);
  late ActivitySelection _selection = _initialSelection;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initDefaultTimes();
  }

  Future<void> _initDefaultTimes() async {
    final day = widget.selectedDay;
    final now = DateTime.now();
    final today = logicalDay(now);
    final isToday =
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    // Synchronous fallback so the `late` fields are set before the first
    // build; overwritten below if a prior entry is found for this day.
    if (isToday) {
      final dayStart = DateTime(day.year, day.month, day.day);
      _endTime = now;
      final defaultStart = now.subtract(const Duration(minutes: 30));
      _startTime = defaultStart.isBefore(dayStart) ? dayStart : defaultStart;
    } else {
      _startTime = DateTime(day.year, day.month, day.day, 12, 0);
      _endTime = DateTime(day.year, day.month, day.day, 12, 30);
    }

    List<TimeEntry> entries;
    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      entries = await dbService.getEntriesForDay(day);
    } catch (_) {
      return;
    }
    if (!mounted || entries.isEmpty) return;

    final lastEndTime = entries
        .map((e) => DateTime.parse(e.endTime))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    setState(() {
      _startTime = lastEndTime;
      if (isToday) {
        _endTime = now.isBefore(lastEndTime) ? lastEndTime : now;
      } else {
        final dayEnd = DateTime(day.year, day.month, day.day, 23, 59);
        final defaultEnd = lastEndTime.add(const Duration(minutes: 30));
        _endTime = defaultEnd.isAfter(dayEnd) ? dayEnd : defaultEnd;
      }
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _setTimes(DateTime start, DateTime end) {
    final timeOrderError = AppLocalizations.of(context).time_errorEndBeforeStart;
    setState(() {
      _startTime = start;
      _endTime = end;
      if (!_endTime.isAfter(_startTime)) {
        _error = timeOrderError;
      } else if (_error == timeOrderError) {
        _error = null;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _customNameMissing =>
      hasCustomNameField(_selection.typeKey) &&
      _selection.customName.trim().isEmpty;

  bool get _descriptionMissing =>
      isDescriptionRequired(_selection.typeKey) &&
      _controller.text.trim().isEmpty;

  bool get _canSubmit =>
      !_descriptionMissing && !_saving && !_customNameMissing;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_descriptionMissing) {
      setState(() => _error = l10n.time_errorDescriptionEmpty);
      return;
    }
    if (!_endTime.isAfter(_startTime)) {
      setState(() => _error = l10n.time_errorEndBeforeStart);
      return;
    }
    if (!_canSubmit) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider).value;
      if (dbService == null) {
        setState(() {
          _error = l10n.time_errorDatabaseUnavailable;
          _saving = false;
        });
        return;
      }

      final values = _selection.toRowValues();

      await dbService.insertTimeEntry(
        TimeEntriesCompanion(
          startTime: Value(_startTime.toIso8601String()),
          endTime: Value(_endTime.toIso8601String()),
          description: Value(_controller.text.trim()),
          activityType: Value(_selection.typeKey),
          project: Value(values.project),
          subtype: Value(values.subtype),
          customName: Value(values.customName),
        ),
      );

      final scope = suggestionScopeOf(_selection.typeKey, values.subtype);
      final name = values.project ?? values.customName;
      if (scope != null && name != null) {
        await ref.read(projectServiceProvider).saveName(scope, name);
        ref.invalidate(suggestionsProvider);
      }

      if (mounted) Navigator.of(context).pop();
    } on OverlappingEntryException catch (e) {
      setState(() {
        _error = l10n.time_errorOverlap(
          _formatTime(DateTime.parse(e.conflict.startTime).toLocal()),
          _formatTime(DateTime.parse(e.conflict.endTime).toLocal()),
        );
        _saving = false;
      });
    } catch (_) {
      setState(() {
        _error = l10n.time_errorSaveEntryFailed;
        _saving = false;
      });
    }
  }

  int _pickerGeneration = 0;

  void _resetForm() {
    setState(() {
      _controller.clear();
      _selection = _initialSelection;
      _pickerGeneration++;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppSheet(
      title: strings.time_manualEntryTitle,
      primaryLabel: strings.time_commonSave,
      primaryEnabled: _canSubmit,
      onPrimary: _submit,
      headerAction: HeaderAction(
        icon: IconAsset.refresh,
        semanticLabel: strings.time_descriptionClearFormTooltip,
        onPressed: _saving ? null : _resetForm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntryTimeFields(
            start: _startTime,
            end: _endTime,
            lastDay: DateTime.now(),
            onChanged: _setTimes,
          ),
          const SizedBox(height: Space.s16),
          ActivityPicker(
            key: ValueKey(_pickerGeneration),
            theme: widget.theme,
            initial: _initialSelection,
            onChanged: (selection) => setState(() => _selection = selection),
          ),
          const SizedBox(height: Space.s16),
          AppTextField(
            controller: _controller,
            multiline: true,
            maxLength: 500,
            hint: strings.time_descriptionHint,
            onChanged: (_) => setState(() {}),
          ),
          if (_error case final error?)
            Text(
              error,
              style: context.bodyText.bodySmall?.copyWith(
                color: context.palette.destructiveText,
              ),
            ),
        ],
      ),
    );
  }
}
