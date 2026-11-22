import 'package:flutter/material.dart';

import '../../../domain/note_node.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';

/// The current folder path with the end kept visible on narrow screens.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.path});

  final List<NoteNode> path;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final pathText = [
      strings.notes_title,
      for (final folder in path) folder.name,
    ].join(' › ');
    final style = context.bodyText.bodySmall?.copyWith(
      color: context.palette.textDim,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        );
        bool fits(String text) {
          painter.text = TextSpan(text: text, style: style);
          painter.layout();
          return painter.width <= constraints.maxWidth;
        }

        var visible = pathText;
        if (!fits(pathText)) {
          final characters = pathText.characters;
          var low = 0;
          var high = characters.length;
          while (low < high) {
            final middle = (low + high + 1) ~/ 2;
            if (fits('…${characters.takeLast(middle)}')) {
              low = middle;
            } else {
              high = middle - 1;
            }
          }
          visible = '…${characters.takeLast(low)}';
        }
        painter.dispose();
        return Text(
          visible,
          semanticsLabel: pathText,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: style,
        );
      },
    );
  }
}
