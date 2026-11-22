import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text.toUpperCase(),
      style: context.bodyText.labelSmall?.copyWith(
        color: context.palette.textFaint,
      ),
    ),
  );
}

class CountHeader extends StatelessWidget {
  const CountHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = context.bodyText.titleLarge;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Row(
              children: [
                Flexible(child: Text(title, style: style)),
                if (count case final number?) ...[
                  const SizedBox(width: Space.s6),
                  Text(
                    '$number',
                    style: style?.copyWith(
                      color: context.palette.textFaint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (trailing case final widget?) ...[
          const SizedBox(width: Space.s8),
          widget,
        ],
      ],
    );
  }
}
