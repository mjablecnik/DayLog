import 'package:flutter/material.dart';

import '../../../core/event_type.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/controls/choice_chip.dart';

/// The small coloured label of one event inside a day cell.
///
/// Uses the event colour as a tint and clips the label within the day cell.
class EventChip extends StatelessWidget {
  const EventChip({
    super.key,
    required this.type,
    required this.label,
    this.continuesBefore = false,
    this.continuesAfter = false,
  });

  final EventType type;
  final String label;

  /// The event goes on to the previous / next week row: that end is square, as
  /// the bar runs on.
  final bool continuesBefore;
  final bool continuesAfter;

  /// The largest text scale a chip follows, so a chip stays inside its cell.
  static const double maxTextScale = 1.3;

  static const double _fontSize = 11;

  /// The height a chip takes at the ambient text scale.
  static double heightOf(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxTextScale);
    return scaler.scale(_fontSize) * 1.35 + Space.s2;
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color color = p.eventColor(type);
    final TextScaler scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxTextScale);
    return Container(
      width: double.infinity,
      height: heightOf(context),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: Space.s2),
      decoration: BoxDecoration(
        color: tintFill(color, p.board, 0.26),
        borderRadius: BorderRadius.horizontal(
          left: continuesBefore ? Radius.zero : const Radius.circular(Radii.chipSmall),
          right: continuesAfter ? Radius.zero : const Radius.circular(Radii.chipSmall),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.clip,
        softWrap: false,
        textScaler: scaler,
        style: context.bodyText.bodySmall!.copyWith(
          fontSize: _fontSize,
          fontWeight: const FontWeight(650),
          height: 1.35,
          color: tintInk(color, p.text, 0.40),
        ),
      ),
    );
  }
}

/// The type of an event as a pill with its colour dot and name, in the same
/// style as its chip (a notable day is soft).
class EventTypeBadge extends StatelessWidget {
  const EventTypeBadge({super.key, required this.type, required this.label});

  final EventType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color color = p.eventColor(type);
    final bool soft = type.isSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s10, vertical: Space.s4),
      decoration: BoxDecoration(
        color: soft ? p.eventSoftFill(type) : color,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: soft ? Border.all(color: color, width: Metrics.hairline) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: Space.s8,
            height: Space.s8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: soft ? color : p.eventChipInk.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: Space.s6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyText.bodySmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: soft ? p.text : p.eventChipInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
