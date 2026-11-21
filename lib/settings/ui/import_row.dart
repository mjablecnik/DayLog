import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/import/database_importer.dart';
import '../../database/import/export_file.dart';
import '../../database/import/import_providers.dart';
import '../../database/import/import_report.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/quest_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/app_icon.dart';
import '../../ui_kit/common/snackbar_host.dart';
import '../../ui_kit/sheet/confirm_destructive.dart';

/// Asks the user for an export file and returns its text, or null when the
/// user cancels. Tests replace it; the real one opens the system file picker.
final importFileReaderProvider = Provider<Future<String?> Function()>((ref) {
  return () async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
    );
    final String? path = file?.path;
    if (path == null) return null;
    return File(path).readAsString();
  };
});

/// Row in the Data group: loads an export file of QuestLog, TimeLog or the app,
/// asks before it replaces anything, and shows what was loaded.
class ImportRow extends ConsumerStatefulWidget {
  const ImportRow({super.key});

  @override
  ConsumerState<ImportRow> createState() => _ImportRowState();
}

class _ImportRowState extends ConsumerState<ImportRow> {
  bool _busy = false;

  Future<void> _import() async {
    if (_busy) return;
    final AppLocalizations l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final String? text = await ref.read(importFileReaderProvider)();
      if (text == null || !mounted) return;
      final ExportFile file = ExportFile.parse(text);
      final DatabaseImporter importer = ref.read(databaseImporterProvider);
      final Map<String, int> current = await importer.currentCounts(file);
      if (!mounted) return;
      final bool confirmed = await confirmDestructive(
        context,
        title: l.settings_importConfirmTitle,
        body: l.settings_importConfirmBody(
          file.header.app,
          file.header.appVersion,
          _date(file.header.exportedAt),
          <String>[
            for (final MapEntry<String, List<Map<String, Object?>>> t in file.tables.entries)
              l.settings_importSummaryLine(t.key, t.value.length, current[t.key] ?? 0),
          ].join('\n'),
        ),
        confirmLabel: l.settings_importConfirmAction,
      );
      if (!confirmed || !mounted) return;
      final ImportReport report = await importer.import(file);
      ref.read(importCounterProvider.notifier).increment();
      if (!mounted) return;
      await _showReport(report);
    } on ImportFailure catch (failure) {
      if (mounted) showAppSnack(context, _failureText(l, failure));
    } catch (_) {
      if (mounted) showAppSnack(context, l.settings_importFailedGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showReport(ImportReport report) {
    final AppLocalizations l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l.settings_importDoneTitle),
        content: Text(
          <String>[
            l.settings_importDoneBody(report.rowsWritten, report.tables.length),
            if (!report.preferencesWritten) l.settings_importPreferencesFailed,
          ].join('\n\n'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.common_close),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime d) =>
      '${d.day}. ${d.month}. ${d.year}';

  static String _failureText(AppLocalizations l, ImportFailure f) => switch (f.kind) {
    ImportFailureKind.notJson => l.settings_importFailedNotJson,
    ImportFailureKind.wrongFormat => l.settings_importFailedWrongFormat,
    ImportFailureKind.newerFormat => l.settings_importFailedNewerFormat,
    ImportFailureKind.missingSection => l.settings_importFailedMissingSection(f.detail),
    ImportFailureKind.unknownTable => l.settings_importFailedUnknownTable(f.detail),
    ImportFailureKind.unknownColumn => l.settings_importFailedUnknownColumn(f.detail),
    ImportFailureKind.foreignKey => l.settings_importFailedForeignKey(f.detail),
    ImportFailureKind.countMismatch => l.settings_importFailedCountMismatch(f.detail),
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.settings_importTitle,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: _import,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l.settings_importTitle,
                        style: context.bodyText.bodyMedium!.copyWith(color: p.brassText),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        l.settings_importSubtitle,
                        style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
                      ),
                    ],
                  ),
                ),
                AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
