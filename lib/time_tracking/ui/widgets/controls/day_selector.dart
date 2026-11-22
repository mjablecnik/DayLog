import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Multi-select weekday chip row. Days follow Dart's `DateTime.weekday`
/// convention: 1=Monday ... 7=Sunday.
class DaySelector extends StatelessWidget {
  final Set<int> activeDays;
  final ValueChanged<Set<int>> onChanged;
  final AppThemeData theme;

  const DaySelector({
    super.key,
    required this.activeDays,
    required this.onChanged,
    required this.theme,
  });

  void _toggle(int day) {
    final updated = Set<int>.from(activeDays);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final labels = weekdayShortLabels(AppLocalizations.of(context));
    final palette = context.palette;
    return Wrap(
      spacing: Space.s2,
      runSpacing: Space.s4,
      alignment: WrapAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = activeDays.contains(day);
        return Semantics(
          selected: selected,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _toggle(day),
              child: SizedBox.square(
                dimension: Metrics.touchTarget,
                child: Center(
                  child: Container(
                    width: Metrics.nodeIcon,
                    height: Metrics.nodeIcon,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? palette.brass : palette.tone,
                    ),
                    child: Text(
                      labels[index],
                      style: context.bodyText.labelLarge?.copyWith(
                        fontSize: 13,
                        color: selected ? palette.inkOnBrass : palette.textDim,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
