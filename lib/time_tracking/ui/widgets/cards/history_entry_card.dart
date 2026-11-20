import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/activity_types.dart';
import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../sheets/edit_sheet.dart';

class HistoryEntryCard extends ConsumerStatefulWidget {
  final TimeEntry entry;
  final AppThemeData theme;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.theme,
  });

  @override
  ConsumerState<HistoryEntryCard> createState() => _HistoryEntryCardState();
}

class _HistoryEntryCardState extends ConsumerState<HistoryEntryCard> {
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

  String _truncateDescription(String desc, {int maxLen = 50}) {
    if (desc.length <= maxLen) return desc;
    return '${desc.substring(0, maxLen)}...';
  }

  Future<void> _delete(BuildContext context) async {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.time_historyDeleteEntryTitle,
          style: TextStyle(
              color: theme.text, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.time_historyDeleteEntryBody,
          style: TextStyle(color: theme.dim, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.time_commonCancel,
              style: TextStyle(color: theme.dim),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.time_commonDelete,
              style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dbService = ref.read(databaseServiceProvider).value;
      if (dbService == null) {
        if (mounted) setState(() => _deleteError = l10n.time_historyDbUnavailableShort);
        return;
      }
      await dbService.deleteEntry(widget.entry.id);
    } catch (_) {
      if (mounted) {
        setState(() => _deleteError = l10n.time_historyDeleteEntryFailed);
      }
    }
  }

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSheet(
        theme: widget.theme,
        entry: widget.entry,
      ),
    );
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatTime(entry.startTime)} – ${_formatTime(entry.endTime)}',
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.accent,
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final color = activityEntryColor(
                    entry.activityType,
                    entry.subtype,
                    isDark: theme.isDark,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      activityTypeLabel(l10n, entry.activityType),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _entryDuration(l10n, entry.startTime, entry.endTime),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.dim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _truncateDescription(entry.description),
            style: TextStyle(
              fontSize: 14,
              color: theme.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (meta != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (meta.dotColor != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: meta.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    meta.text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.dim,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (_deleteError != null) ...[
            const SizedBox(height: 6),
            Text(
              _deleteError!,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _edit(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: theme.dim),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _delete(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 18, color: theme.dim),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
