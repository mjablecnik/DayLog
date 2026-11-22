import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/event_type.dart';
import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../state/calendar_state.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/sheet/app_sheet.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import 'calendar_labels.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'month_grid.dart';

/// Opens the Day_Sheet of [date]: its events, all-day first, then by time.
Future<void> showDaySheet(BuildContext context, DateTime date) =>
    showAppSheet<void>(
      context,
      builder: (BuildContext _) => DaySheet(date: date),
    );

class DaySheet extends ConsumerWidget {
  const DaySheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final List<EventOccurrence> events = MonthPage.forDate(
      ref.watch(dayOccurrencesProvider(date)).value ??
          const <EventOccurrence>[],
      date,
    );
    return AppSheet(
      title: dayHeading(date, l.localeName),
      subtitle: l.calendar_dayEvents(events.length),
      primaryLabel: l.calendar_add,
      primaryIcon: IconAsset.plus,
      onPrimary: () async => showEventForm(context, presetDate: date),
      child: events.isEmpty
          ? Semantics(
              liveRegion: true,
              child: Text(
                l.calendar_dayEmpty,
                style: context.bodyText.bodyLarge?.copyWith(
                  color: context.palette.textDim,
                ),
              ),
            )
          : GroupedList(
              children: [
                for (final event in events)
                  _EventRow(occurrence: event, date: date),
              ],
            ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.occurrence, required this.date});

  final EventOccurrence occurrence;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final CalendarEvent event = occurrence.event;
    final EventType type = event.type;
    final Color color = p.eventColor(type);
    final ({String start, String end})? times = timesOn(
      event,
      occurrence.start,
      date,
    );
    final TextStyle timeStyle = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
    );
    final String time = times == null
        ? l.calendar_allDay
        : '${times.start} – ${times.end}';
    return Semantics(
      button: true,
      label: '${event.name}, ${eventTypeName(l, type)}, $time',
      excludeSemantics: true,
      onTap: () => showEventDetail(context, event.id, occurrence.start),
      child: InkWell(
        key: ValueKey<String>('day-event-${event.id}-${occurrence.start.day}'),
        onTap: () => showEventDetail(context, event.id, occurrence.start),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: Metrics.touchTarget + Space.s16,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.s10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: Space.s48 + Space.s8,
                    child: times == null
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              l.calendar_allDay,
                              textAlign: TextAlign.right,
                              style: context.bodyText.labelSmall!.copyWith(
                                color: p.textFaint,
                                letterSpacing: 0,
                                fontSize: 10.5,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(times.start, style: timeStyle),
                              Text(times.end, style: timeStyle),
                            ],
                          ),
                  ),
                  const SizedBox(width: Space.s12),
                  Container(
                    width: Space.s4,
                    decoration: BoxDecoration(
                      color: type.isSoft ? color.withValues(alpha: 0.6) : color,
                      borderRadius: BorderRadius.circular(Space.s2),
                    ),
                  ),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          event.name,
                          style: context.bodyText.titleMedium!.copyWith(
                            decoration: occurrence.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: p.textFaint,
                          ),
                        ),
                        Text(
                          eventTypeName(l, type),
                          style: context.bodyText.bodySmall!.copyWith(
                            color: p.textDim,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
