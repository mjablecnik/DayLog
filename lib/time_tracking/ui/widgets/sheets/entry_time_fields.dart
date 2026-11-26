import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/tokens.dart';
import '../../../../theme/app_theme.dart';
import '../../../../ui_kit/layout/section_headers.dart';

/// The start and the end of an entry, each one field showing its time and its
/// day. An entry can lie on any past day and can run past midnight.
///
/// Changing the start day moves the whole entry, keeping its length. Picking an
/// end time that would fall before the start on the same day puts the end on
/// the next day, which is the one way an end can come before a start by clock.
class EntryTimeFields extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  /// The last day the date pickers offer (today).
  final DateTime lastDay;
  final void Function(DateTime start, DateTime end) onChanged;

  const EntryTimeFields({
    super.key,
    required this.start,
    required this.end,
    required this.lastDay,
    required this.onChanged,
  });

  static DateTime _at(DateTime day, int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  static DateTime _dayOf(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<DateTime?> _pickDay(BuildContext context, DateTime current) {
    final last = _dayOf(lastDay);
    final initial = _dayOf(current);
    return showDatePicker(
      context: context,
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: DateTime(2020),
      lastDate: initial.isAfter(last) ? initial : last,
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, DateTime current) =>
      showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));

  Future<void> _pickStartDay(BuildContext context) async {
    final picked = await _pickDay(context, start);
    if (picked == null) return;
    final shift = DateUtils.dateOnly(picked).difference(_dayOf(start)).inDays;
    onChanged(
      _at(picked, start.hour, start.minute),
      _at(DateTime(end.year, end.month, end.day + shift), end.hour, end.minute),
    );
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final picked = await _pickTime(context, start);
    if (picked == null) return;
    onChanged(_at(start, picked.hour, picked.minute), end);
  }

  Future<void> _pickEndDay(BuildContext context) async {
    final picked = await _pickDay(context, end);
    if (picked == null) return;
    onChanged(start, _at(picked, end.hour, end.minute));
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final picked = await _pickTime(context, end);
    if (picked == null) return;
    var updated = _at(end, picked.hour, picked.minute);
    if (DateUtils.isSameDay(end, start) && updated.isBefore(start)) {
      updated = _at(
        DateTime(start.year, start.month, start.day + 1),
        picked.hour,
        picked.minute,
      );
    }
    onChanged(start, updated);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dayFormat = DateFormat.MMMEd(strings.localeName);
    return Row(
      children: [
        Expanded(
          child: _DateTimeBox(
            label: strings.time_timeFieldStart,
            daySemantics: strings.time_dayFieldStart,
            day: dayFormat.format(start),
            time: _formatTime(start),
            onDay: () => _pickStartDay(context),
            onTime: () => _pickStartTime(context),
          ),
        ),
        const SizedBox(width: Space.s12),
        Expanded(
          child: _DateTimeBox(
            label: strings.time_timeFieldEnd,
            daySemantics: strings.time_dayFieldEnd,
            day: dayFormat.format(end),
            time: _formatTime(end),
            onDay: () => _pickEndDay(context),
            onTime: () => _pickEndTime(context),
          ),
        ),
      ],
    );
  }
}

/// One field that shows a time and a day, with its label above it. The time
/// and the day are separate tap targets: the time opens a time picker, the day
/// a date picker, so changing only the time stays a single tap.
class _DateTimeBox extends StatelessWidget {
  final String label;
  final String daySemantics;
  final String day;
  final String time;
  final VoidCallback onDay;
  final VoidCallback onTime;

  const _DateTimeBox({
    required this.label,
    required this.daySemantics,
    required this.day,
    required this.time,
    required this.onDay,
    required this.onTime,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final valueStyle = context.bodyText.titleMedium?.copyWith(
      fontSize: 17,
      color: palette.text,
      fontWeight: FontWeight.w600,
    );

    Widget part({
      required String value,
      required String semantics,
      required VoidCallback onTap,
      required EdgeInsets padding,
    }) =>
        Semantics(
          button: true,
          label: semantics,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
              child: Padding(
                padding: padding,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: Text(
                    value,
                    style: valueStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: Space.s8),
        Material(
          color: palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.field),
            side: BorderSide(color: palette.boardLine, width: Metrics.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                part(
                  value: time,
                  semantics: label,
                  onTap: onTime,
                  padding: const EdgeInsets.fromLTRB(
                    Space.s14,
                    Space.s12,
                    Space.s10,
                    Space.s12,
                  ),
                ),
                VerticalDivider(
                  width: Metrics.hairline,
                  thickness: Metrics.hairline,
                  indent: Space.s10,
                  endIndent: Space.s10,
                  color: palette.boardLine,
                ),
                Expanded(
                  child: part(
                    value: day,
                    semantics: daySemantics,
                    onTap: onDay,
                    padding: const EdgeInsets.fromLTRB(
                      Space.s10,
                      Space.s12,
                      Space.s14,
                      Space.s12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
