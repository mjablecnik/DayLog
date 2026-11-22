import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/repeat_rule.dart';
import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../sheets/delete_event_sheet.dart';
import '../state/calendar_state.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../widgets/calendar_fields.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/controls/app_buttons.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/layout/header_action.dart';
import '../../../ui_kit/controls/choice_chip.dart';
import '../../../ui_kit/sheet/menu_sheet.dart';
import '../../../ui_kit/common/snackbar_host.dart';
import 'calendar_labels.dart';
import 'event_form_screen.dart';

/// Opens the detail of the occurrence of event [eventId] that starts on [date].
Future<void> showEventDetail(BuildContext context, int eventId, DateTime date) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => EventDetailScreen(
        eventId: eventId,
        occurrenceDate: DateTime(date.year, date.month, date.day),
      ),
    ),
  );
}

enum _Menu { edit, duplicate, delete }

/// The read-only view of one event occurrence: name, type, start and end, note,
/// repeat, location and, once completed, when and for how much XP.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId, required this.occurrenceDate});

  final int eventId;
  final DateTime occurrenceDate;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _closing = false;
  bool _loaded = false;

  (int, DateTime) get _key => (widget.eventId, widget.occurrenceDate);

  void _closeGone() {
    if (_closing) return;
    _closing = true;
    final bool wasLoaded = _loaded;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppLocalizations l = AppLocalizations.of(context);
      Navigator.of(context).maybePop();
      if (!wasLoaded) showAppSnack(context, l.calendar_eventGone);
    });
  }

  Future<void> _onMenu(_Menu action, EventOccurrence occurrence) async {
    switch (action) {
      case _Menu.edit:
        await showEventForm(context, editing: occurrence.event, occurrenceDate: occurrence.start);
      case _Menu.duplicate:
        await showEventForm(
          context,
          prefill: EventDraft.fromEvent(occurrence.event).copyWith(
            startDate: occurrence.start,
            endDate: occurrence.end,
            repeat: const NoRepeat(),
          ),
        );
      case _Menu.delete:
        final bool deleted = await deleteEventFlow(context, ref, occurrence.event, occurrence.start);
        if (deleted && mounted) {
          _closing = true;
          Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<EventOccurrence?> async = ref.watch(occurrenceProvider(_key));
    final EventOccurrence? occurrence = async.value;
    if (occurrence != null) _loaded = true;
    if (async is AsyncData<EventOccurrence?> && occurrence == null) _closeGone();

    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        child: occurrence == null
            ? const SizedBox.expand()
            : Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _TopBar(onMenu: (_Menu a) => _onMenu(a, occurrence)),
                      Expanded(child: _Body(occurrence: occurrence)),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: Space.s20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s16),
                      child: AppButton.primary(
                        key: const ValueKey<String>('detail-edit'),
                        label: l.calendar_edit,
                        icon: IconAsset.edit,
                        onPressed: () => _onMenu(_Menu.edit, occurrence),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu});

  final ValueChanged<_Menu> onMenu;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppHeader(
      title: '',
      leading: HeaderLeading.close,
      leadingKey: const ValueKey<String>('detail-close'),
      trailing: [
        HeaderAction(
          key: const ValueKey<String>('detail-menu'),
          icon: IconAsset.more,
          semanticLabel: strings.calendar_menu,
          onPressed: () async {
            final action = await showMenuSheet<_Menu>(
              context,
              title: strings.calendar_menu,
              items: [
                (value: _Menu.edit, label: strings.calendar_edit, icon: IconAsset.edit, destructive: false),
                (value: _Menu.duplicate, label: strings.calendar_duplicate, icon: IconAsset.plus, destructive: false),
                (value: _Menu.delete, label: strings.common_delete, icon: IconAsset.trash, destructive: true),
              ],
            );
            if (action != null && context.mounted) onMenu(action);
          },
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.occurrence});

  final EventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;
    final CalendarEvent event = occurrence.event;
    final EventCompletion? completion = occurrence.completion;

    String when(DateTime date, int? minute) {
      final String d = shortDateLabel(date, locale);
      return minute == null ? d : d;
    }

    Widget moment(String label, DateTime date, int? minute, {required bool start}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.bodyText.titleMedium!.copyWith(color: p.brassText),
            ),
            Text(when(date, minute), style: context.bodyText.titleMedium),
            if (minute != null)
              Text(
                minuteLabel(minute),
                style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
              ),
          ],
        ),
      );
    }

    Widget infoRow(String icon, String label, String value, {VoidCallback? onTap}) {
      return ListRow(
        title: label,
        subtitle: value,
        leading: IconTile(icon),
        onTap: onTap,
      );
    }

    final String repeat = repeatDescription(l, event.repeat, occurrence.start);
    final String? location = event.location;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s64 + Space.s48),
      children: <Widget>[
        CalendarCard(
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(event.name, style: context.displayText.displayMedium),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TypeTag(label: eventTypeName(l, event.type), color: p.eventColor(event.type)),
            ),
            if (event.allDay)
              Row(
                children: <Widget>[
                  moment(l.calendar_start, occurrence.start, null, start: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                    child: AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
                  ),
                  moment(l.calendar_end, occurrence.end, null, start: false),
                ],
              )
            else
              Row(
                children: <Widget>[
                  moment(l.calendar_start, occurrence.start, event.startMinute, start: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                    child: AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
                  ),
                  moment(l.calendar_end, occurrence.end, event.endMinute, start: false),
                ],
              ),
            if (event.allDay)
              Text(
                l.calendar_allDay,
                style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
              ),
          ],
        ),
        const SizedBox(height: Space.s12),
        if (completion != null) ...<Widget>[
          CalendarCard(
            children: <Widget>[
              Semantics(
                liveRegion: true,
                child: Row(
                  children: <Widget>[
                    AppIcon(IconAsset.sealCheck, size: Metrics.iconSize, color: p.brassText),
                    const SizedBox(width: Space.s12),
                    Expanded(
                      child: Text(
                        l.calendar_completedAt(
                          DateFormat.Hm(locale).format(completion.completedAt),
                          completion.awardedXp,
                        ),
                        style: context.bodyText.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s12),
        ],
        GroupedList(
          children: <Widget>[
            infoRow(
              IconAsset.note,
              l.calendar_notes,
              (event.note == null || event.note!.isEmpty) ? l.calendar_notSet : event.note!,
            ),
            infoRow(IconAsset.repeat, l.calendar_repeat, repeat),
            infoRow(
              IconAsset.location,
              l.calendar_location,
              (location == null || location.isEmpty) ? l.calendar_notSet : location,
              onTap: (location == null || location.isEmpty)
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: location));
                      if (context.mounted) showAppSnack(context, l.calendar_locationCopied);
                    },
            ),
          ],
        ),
      ],
    );
  }
}
