import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

import '../core/ui_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import '../ui_kit/common/haptics.dart';
import 'destination.dart';
import 'module.dart';

const moduleButtonKey = ValueKey<String>('module-button');

Key moduleBarTabKey(Destination page) =>
    ValueKey<String>('module-tab-${page.linkName}');

class ModuleBar extends StatelessWidget {
  const ModuleBar({
    super.key,
    required this.location,
    required this.side,
    required this.hasPrevious,
    required this.onSelectPage,
    required this.onOpenLauncher,
    required this.onPreviousModule,
  });

  final ShellLocation location;
  final ModuleButtonSide side;
  final bool hasPrevious;
  final ValueChanged<Destination> onSelectPage;
  final VoidCallback onOpenLauncher;
  final VoidCallback onPreviousModule;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pages = location.module.pages;
    final left = side == ModuleButtonSide.left;
    Widget tab(Destination page) => _ModuleTab(
      key: moduleBarTabKey(page),
      page: page,
      selected: page == location.destination,
      onTap: () => onSelectPage(page),
    );

    final tabs = Expanded(
      child: pages.length == 1
          ? Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: Metrics.singleTabMax,
                child: tab(pages.first),
              ),
            )
          : Row(
              children: [for (final page in pages) Expanded(child: tab(page))],
            ),
    );
    final button = SizedBox(
      width: Metrics.moduleSlot,
      child: Center(
        child: ModuleButton(
          key: moduleButtonKey,
          module: location.module,
          hasPrevious: hasPrevious,
          onTap: onOpenLauncher,
          onSwipe: onPreviousModule,
        ),
      ),
    );
    final divider = VerticalDivider(
      width: Space.s6 + Metrics.hairline + Space.s6,
      thickness: Metrics.hairline,
      indent: Space.s16,
      endIndent: Space.s16,
      color: palette.lineStrong,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.boardRaised,
        border: Border(top: BorderSide(color: palette.boardLine)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: Metrics.barContent,
          child: Row(
            children: left ? [button, divider, tabs] : [tabs, divider, button],
          ),
        ),
      ),
    );
  }
}

class ModuleButton extends StatefulWidget {
  const ModuleButton({
    super.key,
    required this.module,
    required this.onTap,
    required this.onSwipe,
    required this.hasPrevious,
  });

  final Module module;
  final VoidCallback onTap;
  final VoidCallback onSwipe;
  final bool hasPrevious;

  @override
  State<ModuleButton> createState() => _ModuleButtonState();
}

class _ModuleButtonState extends State<ModuleButton> {
  double _distance = 0;
  bool _switched = false;

  void _previous() {
    Haptics.light();
    widget.onSwipe();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppLocalizations.of(context);
    final label = strings.shell_moduleButtonLabel(widget.module.label(strings));

    return Semantics(
      button: true,
      label: label,
      onTap: widget.onTap,
      excludeSemantics: true,
      customSemanticsActions: widget.hasPrevious
          ? {
              CustomSemanticsAction(label: strings.shell_previousModule):
                  _previous,
            }
          : null,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onHorizontalDragStart: (_) {
            _distance = 0;
            _switched = false;
          },
          onHorizontalDragUpdate: (details) {
            _distance += details.delta.dx;
            if (!_switched &&
                widget.hasPrevious &&
                _distance.abs() >= Space.s24) {
              _switched = true;
              _previous();
            }
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.button),
              boxShadow: AppGlow.button(palette),
            ),
            child: Material(
              color: palette.brass,
              borderRadius: BorderRadius.circular(Radii.button),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: SizedBox.square(
                  dimension: Metrics.moduleButton,
                  child: Center(
                    child: AppIcon(
                      widget.module.icon,
                      color: palette.inkOnBrass,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleTab extends StatelessWidget {
  const _ModuleTab({
    super.key,
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final Destination page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected
        ? palette.brassText
        : palette.text.withValues(alpha: 0.58);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(page.icon, color: color),
                const SizedBox(height: Space.s4),
                Text(
                  page.label(AppLocalizations.of(context)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.bodyText.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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
