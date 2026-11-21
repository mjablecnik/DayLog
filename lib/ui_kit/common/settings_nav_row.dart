import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// A card row of the Settings page that opens a page of its own: a title, an
/// optional line under it and a chevron. Every such row looks the same.
class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title. $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: p.boardRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: p.boardLine, width: Metrics.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            child: Padding(
              padding: const EdgeInsets.all(Space.s16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: context.bodyText.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: Space.s4),
                          Text(
                            subtitle!,
                            style: context.bodyText.bodySmall!.copyWith(
                              color: p.textDim,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.s12),
                  AppIcon(
                    IconAsset.chevronRight,
                    size: Metrics.iconSmall,
                    color: p.textFaint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
