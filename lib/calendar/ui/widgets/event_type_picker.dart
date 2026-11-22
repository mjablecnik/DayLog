import 'package:flutter/material.dart';

import '../../../core/event_type.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/calendar_labels.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/controls/choice_chip.dart';

/// The ten event types as Choice_Chips, each tinted with its colour, exactly
/// one selected. Replaces a free colour choice.
class EventTypePicker extends StatelessWidget {
  const EventTypePicker({super.key, required this.selected, required this.onSelected});

  final EventType selected;
  final ValueChanged<EventType> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AppPalette p = context.palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Wrap(
        spacing: Space.s8,
        runSpacing: Space.s8,
        children: <Widget>[
          for (final EventType type in EventType.values)
            ChoiceChipX(
              label: eventTypeName(l, type),
              selected: type == selected,
              color: p.eventColor(type),
              showDot: true,
              onSelected: (_) => onSelected(type),
            ),
        ],
      ),
    );
  }
}
