import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

/// One Note in the list: name, the date of its last edit and a two-line preview.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.name,
    required this.date,
    required this.preview,
    required this.onTap,
  });

  final String name;

  /// Already localized last-edited date ("dnes", "včera", "17. 11.").
  final String date;

  /// The Note_Preview; may be empty.
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s16,
            vertical: Space.s13,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              if (preview.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Space.s2),
                  child: Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyText.bodyMedium?.copyWith(
                      fontSize: 14.5,
                      color: palette.textDim,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
