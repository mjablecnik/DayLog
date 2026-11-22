import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/forms/form_field_box.dart';
import '../../../../ui_kit/layout/header_action.dart';
import '../../../../ui_kit/sheet/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/activity_types.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/suggestions_provider.dart';
import '../activity_picker/activity_picker.dart';

class EditSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final TimeEntry entry;

  const EditSheet({super.key, required this.theme, required this.entry});

  @override
  ConsumerState<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<EditSheet> {
  late final TextEditingController _controller;
  late final ActivitySelection _initialSelection;
  late ActivitySelection _selection;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.description);
    _initialSelection = ActivitySelection(
      typeKey: widget.entry.activityType,
      subtypeKey: widget.entry.subtype,
      project: widget.entry.project ?? '',
      customName: widget.entry.customName ?? '',
    );
    _selection = _initialSelection;
    _startTime = DateTime.parse(widget.entry.startTime).toLocal();
    _endTime = DateTime.parse(widget.entry.endTime).toLocal();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    setState(() {
      final updated = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _startTime = updated;
      } else {
        _endTime = updated;
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

  bool get _canSave =>
      _controller.text.trim().isNotEmpty && !_saving && !_customNameMissing;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = l10n.time_errorDescriptionEmpty);
      return;
    }
    if (!_endTime.isAfter(_startTime)) {
      setState(() => _error = l10n.time_errorEndBeforeStart);
      return;
    }
    if (!_canSave) return;

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

      await dbService.updateDescription(
        widget.entry.id,
        _controller.text.trim(),
        activityType: _selection.typeKey,
        project: Value(values.project),
        subtype: Value(values.subtype),
        customName: Value(values.customName),
        startTime: _startTime,
        endTime: _endTime,
      );

      final scope = suggestionScopeOf(_selection.typeKey, values.subtype);
      final name = values.project ?? values.customName;
      if (scope != null && name != null) {
        await ref.read(projectServiceProvider).saveName(scope, name);
        ref.invalidate(suggestionsProvider);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = l10n.time_errorSaveFailed;
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
      title: strings.time_editSheetTitle,
      primaryLabel: strings.time_commonSave,
      primaryEnabled: _canSave,
      onPrimary: _save,
      headerAction: HeaderAction(
        icon: IconAsset.refresh,
        semanticLabel: strings.time_descriptionClearFormTooltip,
        onPressed: _saving ? null : _resetForm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FormFieldBox(
                  label: strings.time_timeFieldStart,
                  value: _formatTime(_startTime),
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: Space.s12),
              Expanded(
                child: FormFieldBox(
                  label: strings.time_timeFieldEnd,
                  value: _formatTime(_endTime),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s16),
          ActivityPicker(
            key: ValueKey(_pickerGeneration),
            theme: widget.theme,
            initial: _initialSelection,
            onChanged: (selection) => setState(() => _selection = selection),
          ),
          const SizedBox(height: Space.s16),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(hintText: strings.time_descriptionHint),
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
