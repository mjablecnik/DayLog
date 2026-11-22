import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

/// One Note in the list: the whole name and the date of its last edit. The
/// preview text is not drawn (it still reaches a screen reader); every row is
/// at least [_minHeight] tall, so short and long names sit in rows of one size.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.name,
    required this.date,
    required this.preview,
    required this.onTap,
  });

  static const double _minHeight = 64;

  final String name;

  /// Already localized last-edited date ("dnes", "včera", "17. 11.").
  final String date;

  /// The Note_Preview; may be empty. Read out, not drawn.
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;
    return Semantics(
      button: true,
      label: '${strings.a11y_openNote(name)}. $date. $preview',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s16,
              vertical: Space.s13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: context.bodyText.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: Space.s8),
                Text(
                  date,
                  style: context.bodyText.bodySmall?.copyWith(
                    fontSize: 13,
                    color: palette.textFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
