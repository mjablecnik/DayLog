import 'package:flutter/material.dart';

import '../../../domain/activity_types.dart';
import '../../../domain/history_timeline.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

String _clock(DateTime time) {
  final local = time.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// The whole day as one bar: every entry is a segment in its activity colour,
/// placed by its start and end on the time axis, with hour labels underneath.
/// [now] is given only when the selected day is today and draws the marker.
class DayStrip extends StatelessWidget {
  const DayStrip({
    super.key,
    required this.entries,
    required this.isDark,
    this.now,
  });

  final List<TimeEntry> entries;
  final bool isDark;
  final DateTime? now;

  static const double _barHeight = Space.s22;
  static const double _tickLabelWidth = Space.s36;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final range = dayStripRange(entries, now: now);
    final ticks = dayStripTicks(range);
    final spanSeconds = range.end.difference(range.start).inSeconds;

    double at(DateTime time) =>
        (time.toLocal().difference(range.start).inSeconds / spanSeconds).clamp(
          0.0,
          1.0,
        );

    final starts = [for (final e in entries) DateTime.parse(e.startTime)];
    final ends = [for (final e in entries) DateTime.parse(e.endTime)];
    final first = starts.reduce((a, b) => a.isBefore(b) ? a : b);
    final last = ends.reduce((a, b) => a.isAfter(b) ? a : b);

    final tickStyle = context.bodyText.bodySmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: palette.textFaint,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.s16,
        Space.s8,
        Space.s16,
        Space.s4,
      ),
      child: Semantics(
        container: true,
        label: l10n.time_historyStripLabel(_clock(first), _clock(last)),
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(
                color: palette.boardLine,
                width: Metrics.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.s12,
                Space.s12,
                Space.s12,
                Space.s8,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: _barHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: ColoredBox(color: palette.tone),
                            ),
                            for (var i = 0; i < entries.length; i++)
                              Positioned(
                                left: width * at(starts[i]),
                                width: (width * (at(ends[i]) - at(starts[i])))
                                    .clamp(Metrics.hairline, width),
                                top: 0,
                                bottom: 0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: activityEntryColor(
                                      entries[i].activityType,
                                      entries[i].subtype,
                                      isDark: isDark,
                                    ),
                                    border: Border(
                                      right: BorderSide(
                                        color: palette.card,
                                        width: Metrics.hairline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (now case final marker?)
                              if (marker.toLocal().isAfter(range.start) &&
                                  marker.toLocal().isBefore(range.end))
                                Positioned(
                                  left: width * at(marker) - Space.s2 / 2,
                                  width: Space.s2,
                                  top: -Space.s2,
                                  bottom: -Space.s2,
                                  child: ColoredBox(color: palette.text),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Space.s4),
                      SizedBox(
                        height: Space.s16,
                        child: Stack(
                          children: [
                            for (final tick in ticks)
                              Positioned(
                                left: (width * at(tick) - _tickLabelWidth / 2)
                                    .clamp(0.0, width - _tickLabelWidth),
                                width: _tickLabelWidth,
                                child: Text(
                                  '${tick.hour.toString().padLeft(2, '0')}:00',
                                  textAlign: TextAlign.center,
                                  style: tickStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
