import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/activity_types.dart';
import '../../domain/config.dart';
import '../../domain/date_format_utils.dart';
import '../../theme/time_theme.dart';
import '../../../database/app_database.dart' show TimeEntry;
import '../../data/stats_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/common/app_segmented.dart';
import '../../../ui_kit/common/empty_state.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/layout/section_headers.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/history_provider.dart' show logicalDay;
import '../painters/bar_painter.dart';
import '../painters/timeline_painter.dart';
import '../widgets/controls/day_navigator.dart';

DateTime _weekStart(DateTime date) {
  final start = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(start.year, start.month, start.day);
}

bool _isCurrentPeriod(StatsPeriod period, DateTime date) {
  final now = DateTime.now();
  // Use logical day: before dayStartHour counts as previous day
  final today = now.hour < dayStartHour
      ? DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1))
      : DateTime(now.year, now.month, now.day);
  if (period == StatsPeriod.daily) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
  return _weekStart(date) == _weekStart(today);
}

const _swipeVelocityThreshold = 300.0;

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(statisticsProvider);
    final period = ref.watch(statisticsPeriodProvider);
    final date = ref.watch(statisticsDateProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        // The tab bar below already clears the bottom inset.
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              title: l10n.time_statsTitle,
              trailing: [
                SizedBox(
                  width: Metrics.settingsControlWidth,
                  child: AppSegmented<StatsPeriod>(
                    options: [
                      SegmentedOption(value: StatsPeriod.daily, label: l10n.time_statsPeriodDay),
                      SegmentedOption(value: StatsPeriod.weekly, label: l10n.time_statsPeriodWeek),
                    ],
                    selected: period,
                    onChanged: (value) => ref.read(statisticsPeriodProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
            const _DateNav(),
            const SizedBox(height: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() < _swipeVelocityThreshold) return;
                  final step = period == StatsPeriod.daily ? 1 : 7;
                  if (velocity < 0) {
                    if (_isCurrentPeriod(period, date)) return;
                    ref.read(statisticsDateProvider.notifier).state =
                        date.add(Duration(days: step));
                  } else {
                    ref.read(statisticsDateProvider.notifier).state =
                        date.subtract(Duration(days: step));
                  }
                },
                child: statsAsync.when(
                  data: (stats) => _StatsBody(
                    stats: stats,
                    theme: theme,
                    l10n: l10n,
                    timeline: period == StatsPeriod.daily
                        ? _DailyTimeline(entries: stats.entries, day: date, theme: theme)
                        : _WeeklyTimeline(
                            entries: stats.entries,
                            weekStart: _weekStart(date),
                            theme: theme,
                            l10n: l10n,
                          ),
                  ),
                  loading: () => Center(
                    child: CircularProgressIndicator(color: theme.accent),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      l10n.time_statsLoadFailed,
                      style: TextStyle(color: theme.dim),
                    ),
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

class _DateNav extends ConsumerWidget {
  const _DateNav();

  String _label(AppLocalizations l10n, StatsPeriod period, DateTime date) {
    final today = logicalDay(DateTime.now());
    if (period == StatsPeriod.daily) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (date == today) return l10n.time_dayToday;
      if (date == yesterday) return l10n.time_dayYesterday;
      return '${date.day}. ${date.month}. ${date.year}';
    }

    final weekStart = _weekStart(date);
    if (weekStart == _weekStart(today)) return l10n.time_statsThisWeek;
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}. ${weekStart.month}. – ${weekEnd.day}. ${weekEnd.month}. ${weekEnd.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statisticsPeriodProvider);
    final date = ref.watch(statisticsDateProvider);
    final l10n = AppLocalizations.of(context);
    final step = period == StatsPeriod.daily ? 1 : 7;
    final isCurrent = _isCurrentPeriod(period, date);

    final dateFormat = DateFormat.yMMMMd(l10n.localeName);
    final start = _weekStart(date);
    return PeriodNavigator(
      title: _label(l10n, period, date),
      subtitle: period == StatsPeriod.daily
          ? DateFormat.MMMMEEEEd(l10n.localeName).format(date)
          : '${dateFormat.format(start)} – ${dateFormat.format(start.add(const Duration(days: 6)))}',
      onPrevious: () {
        ref.read(statisticsDateProvider.notifier).state =
            date.subtract(Duration(days: step));
      },
      onNext: isCurrent
          ? null
          : () {
              ref.read(statisticsDateProvider.notifier).state =
                  date.add(Duration(days: step));
            },
    );
  }
}

class _DailyTimeline extends StatelessWidget {
  final List<TimeEntry> entries;
  final DateTime day;
  final AppThemeData theme;

  const _DailyTimeline({
    required this.entries,
    required this.day,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;
    return Padding(
      padding: const EdgeInsets.all(Space.s12),
      child: SizedBox(
        height: 48,
        child: CustomPaint(
          painter: TimelinePainter(
            entries: entries,
            day: day,
            theme: theme,
            palette: context.palette,
            isDark: isDark,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _WeeklyTimeline extends StatelessWidget {
  final List<TimeEntry> entries;
  final DateTime weekStart;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _WeeklyTimeline({
    required this.entries,
    required this.weekStart,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;
    final weekdayLabels = weekdayShortLabels(l10n);
    return Padding(
      padding: const EdgeInsets.all(Space.s12),
      child: Column(
        children: [
          for (var i = 0; i < 7; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < 6 ? 6 : 0),
              child: _WeekdayRow(
                label: weekdayLabels[i],
                showHourMarkers: i == 6,
                day: weekStart.add(Duration(days: i)),
                entries: entries,
                theme: theme,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  final String label;
  final DateTime day;
  final List<TimeEntry> entries;
  final AppThemeData theme;
  final bool isDark;
  final bool showHourMarkers;

  const _WeekdayRow({
    required this.label,
    required this.day,
    required this.entries,
    required this.theme,
    required this.isDark,
    required this.showHourMarkers,
  });

  @override
  Widget build(BuildContext context) {
    final dayEntries = entries.where((entry) {
      final start = DateTime.parse(entry.startTime);
      final logical = logicalDay(start);
      return logical.year == day.year &&
          logical.month == day.month &&
          logical.day == day.day;
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: Space.s16,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: theme.dim,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: showHourMarkers ? Space.s32 : Space.s16,
            child: CustomPaint(
              painter: TimelinePainter(
                entries: dayEntries,
                day: day,
                theme: theme,
                isDark: isDark,
                palette: context.palette,
                showHourMarkers: showHourMarkers,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsData stats;
  final AppThemeData theme;
  final AppLocalizations l10n;
  final Widget timeline;

  const _StatsBody({
    required this.stats,
    required this.theme,
    required this.l10n,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final types = stats.byActivityType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Widget total(String label, Duration duration, Color color) => Expanded(
      child: GroupedList(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label),
                const SizedBox(height: Space.s4),
                Text(
                  formatDuration(l10n, duration),
                  style: context.displayText.displayLarge?.copyWith(
                    color: color,
                    fontSize: 34,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.s16, Space.s8, Space.s16, Space.s24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            total(l10n.time_statsTracked, stats.totalTracked, palette.brassText),
            const SizedBox(width: Space.s8),
            total(l10n.time_statsUntracked, stats.untrackedTime, palette.textDim),
          ],
        ),
        const SizedBox(height: Space.s12),
        GroupedList(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stats.totalTracked.inSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.s12,
                      Space.s12,
                      Space.s12,
                      0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.pill),
                      child: SizedBox(
                        height: Space.s12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (index, entry) in types.indexed) ...[
                              if (index > 0) const SizedBox(width: Space.s2),
                              Expanded(
                                flex: entry.value.inSeconds.clamp(1, 1 << 30),
                                child: ColoredBox(
                                  color: activityMainColor(
                                    entry.key,
                                    isDark: theme.isDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                timeline,
              ],
            ),
          ],
        ),
        const SizedBox(height: Space.s16),
        if (types.isEmpty)
          EmptyState(title: l10n.time_statsNoEntriesPeriod, icon: IconAsset.statistics)
        else ...[
          SectionLabel(l10n.time_statsByActivityType),
          const SizedBox(height: Space.s8),
          GroupedList(
            children: [
              for (final entry in types)
                Padding(
                  padding: const EdgeInsets.all(Space.s12),
                  child: _ActivityTypeBar(
                    type: entry.key,
                    duration: entry.value,
                    share: stats.totalTracked.inSeconds == 0
                        ? 0
                        : entry.value.inSeconds / stats.totalTracked.inSeconds,
                    progress: types.first.value.inSeconds == 0
                        ? 0
                        : entry.value.inSeconds / types.first.value.inSeconds,
                    subtypeDurations: stats.bySubtype[entry.key] ?? const {},
                    isDark: theme.isDark,
                    theme: theme,
                    l10n: l10n,
                  ),
                ),
            ],
          ),
        ],
        if (stats.byProject.isNotEmpty) ...[
          const SizedBox(height: Space.s16),
          SectionLabel(l10n.time_statsByProject),
          const SizedBox(height: Space.s8),
          GroupedList(
            children: [
              for (final entry in stats.byProject)
                ListRow(title: entry.name, value: formatDuration(l10n, entry.duration)),
            ],
          ),
        ],
        if (stats.byCustomName.isNotEmpty) ...[
          const SizedBox(height: Space.s16),
          SectionLabel(l10n.time_statsByCustomName),
          const SizedBox(height: Space.s8),
          GroupedList(
            children: [
              for (final entry in stats.byCustomName)
                ListRow(title: entry.name, value: formatDuration(l10n, entry.duration)),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActivityTypeBar extends StatelessWidget {
  final String type;
  final Duration duration;

  /// Share of the total tracked time, shown as a percentage.
  final double share;

  /// Bar length as a fraction of the bar width (scaled to the longest type).
  final double progress;

  /// Time per subtype key of this type; empty for a type without subtypes.
  final Map<String, Duration> subtypeDurations;
  final bool isDark;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _ActivityTypeBar({
    required this.type,
    required this.duration,
    required this.share,
    required this.progress,
    required this.subtypeDurations,
    required this.isDark,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (share * 100).round();
    final registryType = activityTypeOf(type);
    final subtypes = [
      for (final subtype in registryType?.subtypes ?? const <ActivitySubtype>[])
        if ((subtypeDurations[subtype.key] ?? Duration.zero) > Duration.zero)
          subtype,
    ];

    // Segments in registry order; time without a subtype is drawn in the
    // main colour of the type.
    var classified = Duration.zero;
    final segments = <BarSegment>[];
    for (final subtype in subtypes) {
      final time = subtypeDurations[subtype.key]!;
      classified += time;
      segments.add(BarSegment(
        color: isDark ? subtype.dark : subtype.light,
        weight: time.inSeconds.toDouble(),
      ));
    }
    final unclassified = duration - classified;
    if (unclassified > Duration.zero) {
      segments.add(BarSegment(
        color: activityMainColor(type, isDark: isDark),
        weight: unclassified.inSeconds.toDouble(),
      ));
    }

    final palette = context.palette;
    final body = context.bodyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: Space.s10,
              height: Space.s10,
              margin: const EdgeInsets.only(right: Space.s10),
              decoration: BoxDecoration(
                color: activityMainColor(type, isDark: isDark),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                activityTypeLabel(l10n, type),
                style: body.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: const FontWeight(650),
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: formatDuration(l10n, duration),
                    style: TextStyle(
                      color: palette.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' · $percent %',
                    style: TextStyle(color: palette.textDim),
                  ),
                ],
              ),
              style: body.bodyMedium?.copyWith(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: Space.s8),
        SizedBox(
          height: 8,
          child: CustomPaint(
            painter: StackedBarPainter(
              progress: progress,
              segments: segments,
              theme: theme,
            ),
            size: Size.infinite,
          ),
        ),
        for (final subtype in subtypes)
          Padding(
            padding: const EdgeInsets.only(left: Space.s20, top: Space.s8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subtypeLabel(l10n, type, subtype.key),
                    style: body.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: palette.textDim,
                    ),
                  ),
                ),
                Text(
                  formatDuration(l10n, subtypeDurations[subtype.key]!),
                  style: body.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: palette.textDim,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
