import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// Edges of a row in a group whose children are managed by a sliver.
typedef GroupEdges = ({bool first, bool last});

BorderRadius groupedRadius(GroupEdges? edges) => edges == null
    ? BorderRadius.circular(Radii.card)
    : BorderRadius.vertical(
        top: edges.first ? const Radius.circular(Radii.group) : Radius.zero,
        bottom: edges.last ? const Radius.circular(Radii.group) : Radius.zero,
      );

Border groupedBorder(Color color, GroupEdges? edges) {
  final line = BorderSide(color: color, width: Metrics.hairline);
  return Border(
    top: edges?.first == false ? BorderSide.none : line,
    right: line,
    bottom: line,
    left: line,
  );
}

class GroupedList extends StatelessWidget {
  const GroupedList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(Radii.group);
    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.boardLine, width: Metrics.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: Metrics.hairline),
            children[index],
          ],
        ],
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.dimmed = false,
    this.titleColor,
    this.subtitleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool dimmed;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final body = context.bodyText;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Metrics.listRowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Space.s13,
          horizontal: Space.s16,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              if (leading case final widget?) ...[
                widget,
                const SizedBox(width: Space.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: body.titleMedium?.copyWith(color: titleColor),
                    ),
                    if (subtitle case final text?)
                      Text(
                        text,
                        style: body.bodySmall?.copyWith(
                          fontSize: 13.5,
                          color: subtitleColor ?? palette.textDim,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing case final widget?) ...[
                const SizedBox(width: Space.s8),
                widget,
              ] else if (value case final text?) ...[
                const SizedBox(width: Space.s8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.35,
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.end,
                    style: body.bodyMedium?.copyWith(
                      fontSize: 14.5,
                      color: palette.textDim,
                    ),
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: Space.s8),
                AppIcon(
                  IconAsset.chevronRight,
                  size: Space.s20,
                  color: palette.textFaint,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        child: Opacity(
          opacity: dimmed ? 0.5 : 1,
          child: onTap == null ? row : InkWell(onTap: onTap, child: row),
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.size = Metrics.iconTile,
    this.destructive = false,
  });

  final String icon;
  final double size;

  /// Tints the tile as the icon of a destructive action.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: destructive
            ? palette.destructive.withValues(alpha: 0.14)
            : palette.brassSoft,
        borderRadius: BorderRadius.circular(Radii.iconTile),
      ),
      child: AppIcon(
        icon,
        size: Space.s20,
        color: destructive ? palette.destructiveText : palette.brassText,
      ),
    );
  }
}

class AddRow extends StatelessWidget {
  const AddRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.listRowMin),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Space.s13,
                horizontal: Space.s16,
              ),
              child: Row(
                children: [
                  AppIcon(
                    IconAsset.plus,
                    size: Space.s20,
                    color: palette.brassText,
                  ),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Text(
                      label,
                      style: context.bodyText.titleMedium?.copyWith(
                        color: palette.brassText,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
