import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../state/calendar_state.dart';
import '../screens/calendar_labels.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/sheet/app_sheet.dart';

/// Opens the month picker: a year stepper (2000 to 2100) and the twelve months.
Future<void> showMonthPicker(BuildContext context) => showAppSheet<void>(
  context,
  builder: (BuildContext _) => const _MonthPickerSheet(),
);

class _MonthPickerSheet extends ConsumerStatefulWidget {
  const _MonthPickerSheet();

  @override
  ConsumerState<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends ConsumerState<_MonthPickerSheet> {
  late int _year = ref.read(visibleMonthProvider).year;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime visible = ref.watch(visibleMonthProvider);
    return AppSheet(
      title: l.calendar_monthPickerTitle,
      primaryLabel: l.calendar_filterDone,
      onPrimary: () async => AppSheet.close<void>(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _YearButton(
                icon: IconAsset.chevronLeft,
                label: l.calendar_prevYear,
                onTap: _year > 2000 ? () => setState(() => _year--) : null,
              ),
              Semantics(
                header: true,
                child: Text('$_year', style: context.displayText.titleLarge),
              ),
              _YearButton(
                icon: IconAsset.chevronRight,
                label: l.calendar_nextYear,
                onTap: _year < 2100 ? () => setState(() => _year++) : null,
              ),
            ],
          ),
          const SizedBox(height: Space.s8),
          GroupedList(
            children: [
              for (int month = 1; month <= 12; month++)
                Semantics(
                  selected: visible.year == _year && visible.month == month,
                  child: ListRow(
                    key: ValueKey<String>('picker-month-$month'),
                    title: monthName(DateTime(_year, month), l.localeName),
                    trailing: visible.year == _year && visible.month == month
                        ? AppIcon(
                            IconAsset.check,
                            color: context.palette.brassText,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(visibleMonthProvider.notifier)
                          .show(DateTime(_year, month));
                      AppSheet.close<void>(context);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YearButton extends StatelessWidget {
  const _YearButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: AppIcon(
              icon,
              size: Metrics.iconSmall,
              color: onTap == null ? p.textFaint : p.text,
            ),
          ),
        ),
      ),
    );
  }
}
