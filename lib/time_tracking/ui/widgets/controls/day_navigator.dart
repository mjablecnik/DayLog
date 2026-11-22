import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/clock_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/history_provider.dart';

class DayNavigator extends ConsumerWidget {
  final AppThemeData theme;

  const DayNavigator({super.key, required this.theme});

  String _dayLabel(AppLocalizations l10n, DateTime day, DateTime now) {
    final todayDate = logicalDay(now);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (day.year == todayDate.year &&
        day.month == todayDate.month &&
        day.day == todayDate.day) {
      return l10n.time_dayToday;
    }
    if (day.year == yesterday.year &&
        day.month == yesterday.month &&
        day.day == yesterday.day) {
      return l10n.time_dayYesterday;
    }

    return '${day.day}. ${day.month}. ${day.year}';
  }

  bool _isToday(DateTime day, DateTime now) {
    final today = logicalDay(now);
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedDay = ref.watch(selectedDayProvider);
    final clock = ref.watch(clockProvider);
    final now = clock.now();
    final isToday = _isToday(selectedDay, now);

    return PeriodNavigator(
      title: _dayLabel(l10n, selectedDay, now),
      subtitle: DateFormat.yMMMMEEEEd(l10n.localeName).format(selectedDay),
      onPrevious: () {
        ref.read(selectedDayProvider.notifier).state = selectedDay.subtract(
          const Duration(days: 1),
        );
      },
      onNext: isToday
          ? null
          : () {
              ref.read(selectedDayProvider.notifier).state = selectedDay.add(
                const Duration(days: 1),
              );
            },
      onTitleTap: () async {
        final now = clock.now();
        final today = DateTime(now.year, now.month, now.day);
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDay,
          firstDate: DateTime(2020),
          lastDate: today,
        );
        if (picked != null && context.mounted) {
          ref.read(selectedDayProvider.notifier).state = picked;
        }
      },
    );
  }
}

class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPrevious,
    required this.onNext,
    this.onTitleTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;

    Widget arrow(String name, String label, VoidCallback? onPressed) =>
        IconButton(
          tooltip: label,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: palette.tone,
            foregroundColor: palette.textDim,
            disabledForegroundColor: palette.textFaint,
          ),
          icon: AppIcon(
            name,
            color: onPressed == null ? palette.textFaint : palette.textDim,
          ),
        );

    final heading = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.bodyText.titleLarge?.copyWith(
              fontSize: 19,
              fontWeight: const FontWeight(750),
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.bodyText.bodySmall?.copyWith(
              fontSize: 13,
              color: palette.textDim,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s16),
      child: Row(
        children: [
          arrow(IconAsset.chevronLeft, strings.time_previousPeriod, onPrevious),
          Expanded(
            child: onTitleTap == null
                ? heading
                : InkWell(onTap: onTitleTap, child: heading),
          ),
          arrow(IconAsset.chevronRight, strings.time_nextPeriod, onNext),
        ],
      ),
    );
  }
}
