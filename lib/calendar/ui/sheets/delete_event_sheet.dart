import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repeat_rule.dart';
import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/calendar_providers.dart';
import '../../services/calendar_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/snackbar_host.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/sheet/confirm_destructive.dart';
import '../../../ui_kit/sheet/app_sheet.dart';

/// Deletes the occurrence of [event] that starts on [occurrenceDate], after
/// asking: one confirmation for an event without a repeat, a sheet with the
/// three scopes for a repeating one.
///
/// On success it shows a snackbar with "Zpět" that restores everything the
/// deletion removed, and resolves to true; the caller then closes its screens.
/// A failure shows a message, keeps the event and resolves to false.
Future<bool> deleteEventFlow(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent event,
  DateTime occurrenceDate,
) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final CalendarService service = ref.read(calendarServiceProvider);
  DeleteScope? scope;
  if (event.repeat is NoRepeat) {
    final bool ok = await confirmDestructive(
      context,
      title: l.calendar_deleteTitle,
      body: l.calendar_deleteBody(event.name),
      confirmLabel: l.common_delete,
    );
    if (ok) scope = DeleteScope.all;
  } else {
    scope = await showAppSheet<DeleteScope>(
      context,
      builder: (BuildContext _) => _DeleteScopeSheet(name: event.name),
    );
  }
  if (scope == null || !context.mounted) return false;
  try {
    final DeletedEventSnapshot snapshot = await service.deleteOccurrence(
      event.id,
      occurrenceDate,
      scope,
    );
    if (!context.mounted) return true;
    showAppSnack(
      context,
      l.calendar_deleted(event.name),
      actionLabel: l.calendar_undo,
      onAction: () => service.restore(snapshot),
    );
    return true;
  } catch (_) {
    if (context.mounted) showAppSnack(context, l.calendar_deleteFailed);
    return false;
  }
}

class _DeleteScopeSheet extends StatelessWidget {
  const _DeleteScopeSheet({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    Widget choice(DeleteScope scope, String label) => ListRow(
      key: ValueKey<String>('delete-${scope.name}'),
      title: label,
      titleColor: p.destructiveText,
      onTap: () => AppSheet.close(context, scope),
    );
    return AppSheet(
      title: l.calendar_deleteTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.calendar_deleteRepeatBody(name),
            style: context.bodyText.bodyLarge?.copyWith(color: p.textDim),
          ),
          const SizedBox(height: Space.s16),
          GroupedList(
            children: [
              choice(DeleteScope.onlyThis, l.calendar_deleteOnlyThis),
              choice(
                DeleteScope.thisAndFollowing,
                l.calendar_deleteThisAndFollowing,
              ),
              choice(DeleteScope.all, l.calendar_deleteAll),
            ],
          ),
        ],
      ),
    );
  }
}
