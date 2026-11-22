import 'package:flutter/material.dart';

import '../../domain/event_xp.dart';
import '../../../quests/domain/xp_rules.dart';
import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/calendar_labels.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/controls/check_circle.dart';
import '../../../quests/ui/cards/difficulty_pips.dart';

/// The Difficulty tier whose XP an Event_XP value is.
Difficulty difficultyForXp(int xp) => switch (xp) {
  <= 10 => Difficulty.easy,
  <= 25 => Difficulty.normal,
  <= 50 => Difficulty.hard,
  _ => Difficulty.fullDay,
};

/// The XP an occurrence awards, or awarded when it is completed.
int eventTaskXp(EventOccurrence o) =>
    o.completion?.awardedXp ??
    eventXp(type: o.event.type, allDay: o.event.allDay, duration: o.event.duration);

/// One Event_Task on the Board: a calendar event the user has to do today.
///
/// It looks like a Quest card with the colour dot and name of its type, the
/// time, the effort pips and a calendar mark. It cannot be dragged or swiped.
class EventTaskCard extends StatelessWidget {
  const EventTaskCard({
    super.key,
    required this.occurrence,
    required this.onToggle,
    required this.onTap,
    this.groupEdges,
  });

  final EventOccurrence occurrence;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final GroupEdges? groupEdges;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final CalendarEvent event = occurrence.event;
    final bool done = occurrence.isCompleted;
    final int xp = eventTaskXp(occurrence);
    final Color nameColor = done ? p.textFaint : p.text;
    final Color metaColor = done ? p.textFaint : p.slipTextDim;
    final TextStyle meta = context.bodyText.bodySmall!.copyWith(color: metaColor);
    final String time = event.allDay
        ? l.calendar_taskAllDay
        : '${minuteLabel(event.startMinute!)}–${minuteLabel(event.endMinute!)}';
    final radius = groupedRadius(groupEdges);

    final xpText = DecoratedBox(
      decoration: BoxDecoration(
        color: p.brassSoft,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s4),
        child: Text(
          '+$xp',
          style: context.bodyText.labelLarge?.copyWith(color: p.brassText),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: radius,
        border: groupedBorder(p.boardLine, groupEdges),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s6, Space.s8, Space.s16, Space.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CheckCircle(
                  checked: done,
                  onTap: onToggle,
                  semanticLabel: done ? l.a11y_reopenEvent(event.name) : l.a11y_completeEvent(event.name),
                ),
                const SizedBox(width: Space.s6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          event.name,
                          style: context.bodyText.titleMedium!.copyWith(
                            color: nameColor,
                            decoration: done ? TextDecoration.lineThrough : null,
                            decorationColor: p.textFaint,
                          ),
                        ),
                        const SizedBox(height: Space.s4),
                        Wrap(
                          spacing: Space.s8,
                          runSpacing: Space.s4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: Space.s8,
                                  height: Space.s8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.eventColor(event.type),
                                  ),
                                ),
                                const SizedBox(width: Space.s6),
                                Text(
                                  eventTypeName(l, event.type),
                                  style: meta.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(time, style: meta),
                            DifficultyPips(
                              difficultyForXp(xp),
                              emptyColor: done ? p.textFaint : p.slipTextFaint,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Space.s8),
                done ? Opacity(opacity: 0.7, child: xpText) : xpText,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
