import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/app_segmented.dart';
import '../../ui_kit/common/snackbar_host.dart';

/// A page the guide can make a Home Screen icon for: the name in its
/// `daylog://<name>` link and its localized label.
@immutable
class ShortcutTarget {
  const ShortcutTarget({required this.linkName, required this.label});

  final String linkName;
  final String label;
}

/// Settings guide for a Home Screen icon that opens DayLog on a chosen page:
/// pick the page, copy its `daylog://` link, follow the Shortcuts steps.
///
/// Shown on its own page, opened from a row in Settings. The pages come from the shell, which also reads the links, so the two
/// cannot disagree.
class ShortcutGuide extends StatefulWidget {
  const ShortcutGuide({super.key, required this.targets});

  final List<ShortcutTarget> targets;

  @override
  State<ShortcutGuide> createState() => _ShortcutGuideState();
}

class _ShortcutGuideState extends State<ShortcutGuide> {
  /// The most targets in one row of the picker.
  static const int _perRow = 4;

  late String _target = widget.targets.any((ShortcutTarget t) => t.linkName == 'calendar')
      ? 'calendar'
      : widget.targets.first.linkName;

  String get _link => '$appLinkScheme://$_target';

  Future<void> _copy(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _link));
    if (!context.mounted) return;
    showAppSnack(context, l.settings_shortcutCopied);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final TextStyle small = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
    );

    final List<String> steps = <String>[
      l.settings_shortcutStep1,
      l.settings_shortcutStep2,
      l.settings_shortcutStep3,
      l.settings_shortcutStep4,
      l.settings_shortcutStep5,
      l.settings_shortcutStep6,
    ];

    return Container(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(Space.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(l.settings_shortcutPickLabel, style: small),
                  const SizedBox(height: Space.s8),
                  for (int start = 0; start < widget.targets.length; start += _perRow) ...<Widget>[
                    if (start > 0) const SizedBox(height: Space.s8),
                    AppSegmented<String>(
                      options: <SegmentedOption<String>>[
                        for (final ShortcutTarget t in widget.targets.skip(start).take(_perRow))
                          SegmentedOption<String>(value: t.linkName, label: t.label),
                      ],
                      selected: _target,
                      onChanged: (String name) => setState(() => _target = name),
                    ),
                  ],
                  const SizedBox(height: Space.s16),
                  _LinkBox(link: _link, onCopy: () => _copy(context)),
                  const SizedBox(height: Space.s16),
                  for (int i = 0; i < steps.length; i++)
                    _Step(number: i + 1, text: steps[i]),
                  const SizedBox(height: Space.s4),
                  Text(
                    l.settings_shortcutNote,
                    style: small.copyWith(color: p.textFaint),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The link in a field-coloured box with a copy button beside it.
class _LinkBox extends StatelessWidget {
  const _LinkBox({required this.link, required this.onCopy});

  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.only(left: Space.s16),
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SelectableText(
              link,
              style: context.bodyText.bodyMedium,
            ),
          ),
          Semantics(
            button: true,
            label: l.settings_shortcutCopyLink,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.control),
              onTap: onCopy,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget + Space.s4,
                  minWidth: Metrics.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s16),
                  child: Center(
                    child: Text(
                      l.settings_shortcutCopyLink,
                      style: context.bodyText.bodyMedium!.copyWith(
                        color: p.brassText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One numbered step.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: Space.s24,
            height: Space.s24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.brassSoft,
              shape: BoxShape.circle,
            ),
            child: ExcludeSemantics(
              child: Text(
                '$number',
                style: context.bodyText.labelSmall!.copyWith(
                  color: p.brassText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: Space.s2),
              child: Text(text, style: context.bodyText.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
