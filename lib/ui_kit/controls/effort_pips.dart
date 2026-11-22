import 'package:flutter/widgets.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

class EffortPips extends StatelessWidget {
  const EffortPips({super.key, required this.filled, this.total = 4})
    : assert(total >= 0),
      assert(filled >= 0 && filled <= total);

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < total; index++) ...[
            if (index > 0) const SizedBox(width: Space.s3),
            SizedBox(
              width: Metrics.pipWidth,
              height: Metrics.pipHeight,
              child: DecoratedBox(
                key: ValueKey<String>(index < filled ? 'pip-on' : 'pip-off'),
                decoration: BoxDecoration(
                  color: index < filled ? palette.brass : palette.lineStrong,
                  borderRadius: BorderRadius.circular(Space.s2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
