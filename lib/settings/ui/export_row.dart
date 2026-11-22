import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../ui_providers.dart';
import '../../ui_kit/common/app_icon.dart';
import '../../ui_kit/layout/grouped_list.dart';
import '../../ui_kit/common/snackbar_host.dart';

/// Row in the Data group: saves all app data into one JSON file and opens the
/// share sheet. Ignores taps while an export is running.
class ExportRow extends ConsumerStatefulWidget {
  const ExportRow({super.key});

  @override
  ConsumerState<ExportRow> createState() => _ExportRowState();
}

class _ExportRowState extends ConsumerState<ExportRow> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    // The share sheet anchors on this row on iPad.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final failed = AppLocalizations.of(context).settings_exportFailed;
    setState(() => _busy = true);
    try {
      await ref.read(exportServiceProvider).shareExport(origin: origin);
    } catch (_) {
      if (mounted) showAppSnack(context, failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListRow(
      title: strings.settings_exportTitle,
      leading: const IconTile(IconAsset.upload),
      showChevron: true,
      onTap: _busy ? null : _export,
    );
  }
}
