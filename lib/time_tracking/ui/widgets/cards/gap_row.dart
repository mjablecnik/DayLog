import 'package:flutter/material.dart';

import '../../../domain/date_format_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

/// The unrecorded time between two entries of the History list. It only shows
/// the length; it takes no taps and no swipes.
class GapRow extends StatelessWidget {
  const GapRow({super.key, required this.length});

  final Duration length;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final dash = Expanded(
      child: _DashedLine(color: palette.lineStrong),
    );

    return ColoredBox(
      color: palette.tone,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.s12,
          vertical: Space.s6,
        ),
        child: Row(
          children: [
            const SizedBox(width: Metrics.historyTimeWidth + Space.s4),
            dash,
            const SizedBox(width: Space.s10),
            Text(
              l10n.time_historyGap(formatDuration(l10n, length)),
              style: context.bodyText.bodySmall?.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textDim,
              ),
            ),
            const SizedBox(width: Space.s10),
            const SizedBox(width: Space.s18, child: _DashedLine()),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({this.color});

  final Color? color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? context.palette.lineStrong;
    return SizedBox(
      height: Metrics.hairline * 2,
      child: CustomPaint(painter: _DashPainter(lineColor)),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      final end = x + _DashedLine._dash;
      canvas.drawLine(
        Offset(x, y),
        Offset(end > size.width ? size.width : end, y),
        paint,
      );
      x = end + _DashedLine._gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
