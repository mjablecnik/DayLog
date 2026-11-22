import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/event_type.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/calendar_labels.dart';
import '../state/calendar_state.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/sheet/app_sheet.dart';
import '../../../ui_kit/controls/app_buttons.dart';
import '../../../ui_kit/layout/grouped_list.dart';

/// Opens the Type_Filter sheet: one switch per event type.
Future<void> showTypeFilter(BuildContext context) => showAppSheet<void>(
  context,
  builder: (BuildContext _) => const _TypeFilterSheet(),
);

class _TypeFilterSheet extends ConsumerWidget {
  const _TypeFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final Set<EventType> shown = ref.watch(typeFilterProvider);
    final TypeFilterNotifier notifier = ref.read(typeFilterProvider.notifier);
    return AppSheet(
      title: l.calendar_filterTitle,
      primaryLabel: l.calendar_filterDone,
      onPrimary: () async => AppSheet.close<void>(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GroupedList(
            children: [
              for (final type in EventType.values)
                ListRow(
                  title: eventTypeName(l, type),
                  leading: Container(
                    width: Space.s12,
                    height: Space.s12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.eventColor(type),
                    ),
                  ),
                  trailing: Semantics(
                    label: eventTypeName(l, type),
                    child: Switch(
                      key: ValueKey<String>('filter-${type.key}'),
                      value: shown.contains(type),
                      onChanged: (_) => notifier.toggle(type),
                      activeThumbColor: p.inkOnBrass,
                      activeTrackColor: p.brass,
                      inactiveThumbColor: p.textFaint,
                      inactiveTrackColor: p.field,
                      trackOutlineColor: WidgetStatePropertyAll<Color>(
                        p.boardLine,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (shown.length < EventType.values.length) ...[
            const SizedBox(height: Space.s12),
            AppButton.tonal(
              label: l.calendar_filterShowAll,
              onPressed: notifier.showAll,
            ),
          ],
        ],
      ),
    );
  }
}
