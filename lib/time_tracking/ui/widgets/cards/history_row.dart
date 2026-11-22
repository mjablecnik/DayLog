import 'package:flutter/material.dart';

import '../../../domain/activity_types.dart';
import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/controls/choice_chip.dart';
import '../../../../ui_kit/layout/swipe_actions.dart';

class HistoryRow extends StatefulWidget {
  const HistoryRow({
    super.key,
    required this.entry,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  final TimeEntry entry;
  final AppThemeData theme;
  final VoidCallback onEdit;
  final Future<String?> Function() onDelete;

  @override
  State<HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<HistoryRow> {
  String? _deleteError;

  String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _entryDuration(AppLocalizations l10n, String startIso, String endIso) {
    final start = DateTime.parse(startIso);
    final end = DateTime.parse(endIso);
    return formatDuration(l10n, end.difference(start));
  }

  Future<void> _delete() async {
    final error = await widget.onDelete();
    if (mounted && error != null) setState(() => _deleteError = error);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);
    final meta = entryMetaLine(
      l10n,
      typeKey: entry.activityType,
      subtypeKey: entry.subtype,
      project: entry.project,
      customName: entry.customName,
      isDark: theme.isDark,
    );

    final palette = context.palette;
    final body = context.bodyText;
    final color = activityEntryColor(
      entry.activityType,
      entry.subtype,
      isDark: theme.isDark,
    );
    final timeStyle = body.bodySmall?.copyWith(
      fontSize: 13.5,
      color: palette.textDim,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return SwipeActions(
      groupTag: 'history-entries',
      actions: [
        SwipeActionSpec.edit(
          context,
          key: ValueKey('history-edit-${entry.id}'),
          onPressed: widget.onEdit,
        ),
        SwipeActionSpec.delete(
          context,
          key: ValueKey('history-delete-${entry.id}'),
          onPressed: _delete,
        ),
      ],
      child: InkWell(
        onTap: widget.onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s12,
            vertical: Space.s10,
          ),
          child: Row(
            children: [
              SizedBox(
                width: Metrics.historyTimeWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatTime(entry.startTime), style: timeStyle),
                    Text(_formatTime(entry.endTime), style: timeStyle),
                  ],
                ),
              ),
              Container(
                width: Space.s4,
                height: Metrics.touchTarget,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(Space.s2),
                ),
              ),
              const SizedBox(width: Space.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.description.isNotEmpty)
                      Text(
                        entry.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: body.titleMedium?.copyWith(
                          fontWeight: const FontWeight(650),
                        ),
                      ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Space.s6,
                      runSpacing: Space.s4,
                      children: [
                        TypeTag(
                          label: activityTypeLabel(l10n, entry.activityType),
                          color: color,
                        ),
                        if (meta != null)
                          Text(
                            meta.text,
                            style: body.bodySmall?.copyWith(
                              fontSize: 13,
                              color: palette.textDim,
                            ),
                          ),
                      ],
                    ),
                    if (_deleteError case final error?)
                      Text(
                        error,
                        style: body.bodySmall?.copyWith(
                          color: palette.destructiveText,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Space.s8),
              Text(
                _entryDuration(l10n, entry.startTime, entry.endTime),
                style: body.bodyMedium?.copyWith(
                  fontSize: 14.5,
                  fontWeight: const FontWeight(650),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
