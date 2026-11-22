import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../ui_kit/forms/app_text_field.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/layout/header_action.dart';
import '../../../../ui_kit/sheet/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/activity_types.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../../../providers/timer_provider.dart';
import '../activity_picker/activity_picker.dart';

const _lastSubmittedDescriptionKey = 'last_submitted_description';
const _lastSubmittedActivityTypeKey = 'last_submitted_activity_type';
const _lastSubmittedProjectKey = 'last_submitted_project';
const _lastSubmittedSubtypeKey = 'last_submitted_subtype';
const _lastSubmittedCustomNameKey = 'last_submitted_custom_name';

class DescriptionSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final DateTime sessionStart;
  final DateTime endedAt;
  final bool triggeredByStop;

  const DescriptionSheet({
    super.key,
    required this.theme,
    required this.sessionStart,
    required this.endedAt,
    this.triggeredByStop = false,
  });

  @override
  ConsumerState<DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends ConsumerState<DescriptionSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  /// Selection the picker starts from; null lets the picker restore the last
  /// used type. Replaced when the last submitted entry is loaded or the form
  /// is cleared.
  ActivitySelection? _initialSelection;
  late ActivitySelection _selection;

  /// Bumped to rebuild the picker with a new initial selection.
  int _pickerGeneration = 0;

  @override
  void initState() {
    super.initState();
    _selection = ActivitySelection(typeKey: activityTypes.first);
    _loadLastSubmitted();
  }

  Future<void> _loadLastSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final description = prefs.getString(_lastSubmittedDescriptionKey);
    final activityType = prefs.getString(_lastSubmittedActivityTypeKey);
    final project = prefs.getString(_lastSubmittedProjectKey);
    final subtype = prefs.getString(_lastSubmittedSubtypeKey);
    final customName = prefs.getString(_lastSubmittedCustomNameKey);
    if (!mounted) return;
    setState(() {
      if (description != null) _controller.text = description;
      if (activityType != null && activityTypeOf(activityType) != null) {
        _initialSelection = ActivitySelection(
          typeKey: activityType,
          subtypeKey: subtype,
          project: project ?? '',
          customName: customName ?? '',
        );
        _selection = _initialSelection!;
        _pickerGeneration++;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _controller.clear();
      _initialSelection = ActivitySelection(typeKey: activityTypes.first);
      _selection = _initialSelection!;
      _pickerGeneration++;
    });
  }

  Future<void> _saveLastSubmitted(
    String description,
    ActivitySelection selection,
  ) async {
    final values = selection.toRowValues();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSubmittedDescriptionKey, description);
    await prefs.setString(_lastSubmittedActivityTypeKey, selection.typeKey);
    await prefs.setString(_lastSubmittedProjectKey, values.project ?? '');
    await prefs.setString(_lastSubmittedSubtypeKey, values.subtype ?? '');
    await prefs.setString(_lastSubmittedCustomNameKey, values.customName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// `Ostatní` needs a name to be submitted (Skip still saves without one).
  bool get _customNameMissing =>
      hasCustomNameField(_selection.typeKey) &&
      _selection.customName.trim().isEmpty;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && !_saving && !_customNameMissing;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    await _saveEntry(_controller.text.trim());
  }

  Future<void> _skip() async {
    if (_saving) return;

    final elapsed = widget.endedAt.difference(widget.sessionStart);
    if (elapsed.inSeconds < 120) {
      // Less than 2 minutes — discard without saving.
      if (widget.triggeredByStop) {
        ref.read(timerProvider.notifier).stop();
      } else {
        ref.read(timerProvider.notifier).autoRestart();
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await _saveEntry('');
  }

  Future<void> _saveEntry(String description) async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
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
          startTime: Value(widget.sessionStart.toIso8601String()),
          endTime: Value(widget.endedAt.toIso8601String()),
          description: Value(description),
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

      await _saveLastSubmitted(description, _selection);

      if (widget.triggeredByStop) {
        ref.read(timerProvider.notifier).stop();
      } else {
        ref.read(timerProvider.notifier).autoRestart();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = l10n.time_errorSaveEntryFailed;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppSheet(
      title: strings.time_descriptionTitle,
      primaryLabel: strings.time_commonSave,
      primaryEnabled: _canSubmit,
      onPrimary: _submit,
      headerAction: HeaderAction(
        icon: IconAsset.refresh,
        semanticLabel: strings.time_descriptionClearFormTooltip,
        onPressed: _saving ? null : _resetForm,
      ),
      dismissible: false,
      footer: TextButton(
        onPressed: _saving ? null : _skip,
        style: TextButton.styleFrom(
          foregroundColor: context.palette.textDim,
        ),
        child: Text(strings.time_commonSkip),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
