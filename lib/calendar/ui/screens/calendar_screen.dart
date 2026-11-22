import 'package:flutter/material.dart';

import '../../../ui_kit/controls/step_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/calendar_dates.dart';
import '../../../l10n/app_localizations.dart';
import '../sheets/month_picker_sheet.dart';
import '../sheets/type_filter_sheet.dart';
import '../state/calendar_state.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../../ui_kit/layout/header_action.dart';
import 'calendar_labels.dart';
// import 'event_form_screen.dart'; // add button is switched off
import 'event_search_screen.dart';
import 'month_grid.dart';

/// The Kalendář tab: the Month_View with its header (search and filter; the add
/// button is switched off, events are added from the day sheet).
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = context.palette;
    final bool filterHidesAll = ref.watch(typeFilterProvider).isEmpty;
    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            // The month fills the screen down to the module bar.
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(),
                _WeekdayRow(),
                Expanded(child: MonthPager()),
              ],
            ),
            if (filterHidesAll)
              Positioned(
                left: Space.s16,
                right: Space.s16,
                bottom: Space.s20,
                child: const _FilterHidesAll(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime month = ref.watch(visibleMonthProvider);
    final bool filterActive = ref.watch(typeFilterActiveProvider);
    final VisibleMonthNotifier notifier = ref.read(visibleMonthProvider.notifier);
    final bool canPrevious = isNavigableMonth(DateTime(month.year, month.month - 1));
    final bool canNext = isNavigableMonth(DateTime(month.year, month.month + 1));

    final Widget todayPill = Semantics(
      button: true,
      label: l.calendar_today,
      excludeSemantics: true,
      onTap: notifier.goToToday,
      child: InkWell(
        key: const ValueKey<String>('calendar-today'),
        onTap: notifier.goToToday,
        borderRadius: BorderRadius.circular(Radii.headerAction),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: p.brassSoft,
                borderRadius: BorderRadius.circular(Radii.headerAction),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s6),
                child: Text(
                  l.calendar_today,
                  style: context.bodyText.labelLarge!.copyWith(
                    color: p.brassText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      children: <Widget>[
        AppHeader(
          title: monthName(month, l.localeName),
          titleSuffix: month.year.toString(),
          onTitleTap: () => showMonthPicker(context),
          titleActionLabel: '${monthTitle(month, l.localeName)}. ${l.calendar_pickMonth}',
          trailing: [
            HeaderAction(
              icon: IconAsset.search,
              semanticLabel: l.calendar_search,
              onPressed: () => showEventSearch(context),
            ),
            HeaderAction(
              icon: IconAsset.filter,
              semanticLabel: l.calendar_filter,
              badgeCount: filterActive ? 1 : null,
              onPressed: () => showTypeFilter(context),
            ),
            // The add button is switched off for now; events are added from
            // the day sheet.
            // HeaderAction(
            //   key: const ValueKey<String>('add-fab'),
            //   icon: IconAsset.plus,
            //   semanticLabel: l.calendar_add,
            //   emphasized: true,
            //   onPressed: () => showEventForm(
            //     context,
            //     presetDate: ref.read(selectedDayProvider),
            //   ),
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s8),
          child: Row(
            children: <Widget>[
              StepButton(
                icon: IconAsset.chevronLeft,
                label: l.calendar_prevMonth,
                onPressed: canPrevious ? notifier.previous : null,
                size: 38,
              ),
              const SizedBox(width: Space.s8),
              StepButton(
                icon: IconAsset.chevronRight,
                label: l.calendar_nextMonth,
                onPressed: canNext ? notifier.next : null,
                size: 38,
              ),
              const Spacer(),
              todayPill,
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final String locale = AppLocalizations.of(context).localeName;
    // 2 November 2026 is a Monday.
    final List<String> names = <String>[
      for (int i = 0; i < 7; i++) DateFormat.E(locale).format(DateTime(2026, 11, 2 + i)).toUpperCase(),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8),
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            for (final String name in names)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Space.s6),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: context.bodyText.labelSmall!.copyWith(
                      color: p.textFaint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown over the month while the Type_Filter has no type switched on.
class _FilterHidesAll extends ConsumerWidget {
  const _FilterHidesAll();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.s12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(l.calendar_filterHidesAll, style: context.bodyText.bodyMedium),
            ),
            const SizedBox(height: Space.s8),
            TextButton(
              onPressed: () => ref.read(typeFilterProvider.notifier).showAll(),
              style: TextButton.styleFrom(
                minimumSize: const Size(Metrics.touchTarget, Metrics.touchTarget),
                foregroundColor: p.brassText,
                padding: EdgeInsets.zero,
              ),
              child: Text(l.calendar_filterShowAll, style: context.bodyText.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
