import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../services/providers.dart';
import '../cards/progress_ring.dart';

class LevelCard extends ConsumerWidget {
  const LevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;
    final body = context.bodyText;
    final progress = ref.watch(levelProgressProvider).value;
    final name = ref.watch(settingsProvider).value?.displayName;
    return Container(
      padding: const EdgeInsets.all(Space.s16),
      decoration: BoxDecoration(
        color: palette.brassSoft,
        borderRadius: BorderRadius.circular(Radii.reward),
      ),
      child: Row(
        children: [
          Semantics(
            label: progress == null
                ? null
                : strings.hero_levelBadgeLabel(progress.level),
            child: SizedBox.square(
              dimension: Space.s64,
              child: CustomPaint(
                painter: ProgressRingPainter(
                  done: progress?.xpIntoLevel ?? 0,
                  total: progress?.threshold ?? 0,
                  progressColor: palette.brass,
                  trackColor: palette.lineStrong,
                  strokeWidth: Metrics.heroBar,
                  radius: (Space.s64 - Metrics.heroBar) / 2,
                ),
                child: Center(
                  child: Text(
                    progress == null ? '' : '${progress.level}',
                    style: context.displayText.headlineLarge?.copyWith(
                      color: palette.brassText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Space.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body.bodySmall?.copyWith(
                      fontSize: 13,
                      color: palette.textDim,
                    ),
                  ),
                if (progress != null) ...[
                  Text(
                    strings.hero_level(progress.level),
                    style: body.titleLarge?.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final String full = strings.hero_xpProgress(
                        progress.xpIntoLevel,
                        progress.threshold,
                      );
                      final int cut = full.indexOf(' ');
                      return Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: full.substring(0, cut),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: palette.text,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${full.substring(cut)} · ${strings.hero_xpRemaining(progress.threshold - progress.xpIntoLevel)}',
                            ),
                          ],
                        ),
                        style: body.bodySmall?.copyWith(
                          fontSize: 13,
                          color: palette.textDim,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
