import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// One segment of a [AppSegmented] control.
@immutable
class SegmentedOption<T> {
  const SegmentedOption({
    required this.value,
    required this.label,
    this.icon,
    this.caption,
    this.semanticLabel,
  }) : assert(label != '' || semanticLabel != null);

  final T value;

  /// Already localized.
  final String label;
  final String? semanticLabel;

  /// Optional [IconAsset] name drawn before the label.
  final String? icon;

  /// Optional small second line (for example the XP of a Difficulty).
  final String? caption;
}

/// Pill-style segmented control: a field-coloured track with the selected
/// segment lifted in brass.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<SegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// A disabled control keeps its selection visible but ignores taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bool compact = options.every((SegmentedOption<T> o) => o.caption == null);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Align(
        heightFactor: 1,
        child: compact ? _compactTrack(p) : _roomyTrack(p),
      ),
    );
  }

  /// The pill is drawn [Metrics.segmentTrackHeight] tall while every segment
  /// still reacts to taps over a full [Metrics.touchTarget].
  Widget _compactTrack(AppPalette p) {
    const double inset =
        (Metrics.touchTarget - Metrics.segmentTrackHeight) / 2;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: inset,
            bottom: inset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: p.tone,
                borderRadius: BorderRadius.circular(Radii.control),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s3),
            child: _segments(compact: true),
          ),
        ],
      ),
    );
  }

  /// For options with a caption the segments need their natural height.
  Widget _roomyTrack(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s3),
      decoration: BoxDecoration(
        color: p.tone,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: _segments(compact: false),
    );
  }

  Widget _segments({required bool compact}) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: Space.s4),
          Expanded(
            child: _Segment<T>(
              option: options[i],
              selected: options[i].value == selected,
              enabled: enabled,
              compact: compact,
              onTap: () => onChanged(options[i].value),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment<T> extends StatefulWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  final SegmentedOption<T> option;
  final bool selected;
  final bool enabled;

  /// Draws the pill shorter than the tap area, see [AppSegmented].
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_Segment<T>> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final o = widget.option;
    final bool on = widget.selected;
    final Color foreground = on ? p.brassText : p.textDim;
    final Duration fade = MediaQuery.disableAnimationsOf(context)
        ? Motion.none
        : Motion.hover;

    final Color? background = _pressed ? p.brassSoft : (on ? p.card : null);
    final String label = o.semanticLabel ?? o.label;

    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      enabled: widget.enabled,
      label: o.caption == null ? label : '$label, ${o.caption}',
      excludeSemantics: true,
      onTap: widget.enabled ? widget.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled ? widget.onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.compact
                  ? (Metrics.touchTarget - Metrics.segmentPillHeight) / 2
                  : Space.s3,
            ),
            child: AnimatedContainer(
              duration: fade,
              curve: Motion.curve,
              padding: const EdgeInsets.symmetric(horizontal: Space.s8),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(Radii.segment),
                boxShadow: on && p.isLight ? AppGlow.segment(p) : null,
              ),
              child: Opacity(
                opacity: widget.enabled ? 1 : 0.5,
                child: Center(
                  heightFactor: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (o.icon != null) ...<Widget>[
                            AppIcon(
                              o.icon!,
                              size: Metrics.iconSmall,
                              color: foreground,
                            ),
                            if (o.label.isNotEmpty)
                              const SizedBox(width: Space.s6),
                          ],
                          if (o.label.isNotEmpty)
                            Flexible(
                              child: Text(
                                o.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.bodyText.labelLarge!.copyWith(
                                  color: foreground,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (o.caption != null)
                        Text(
                          o.caption!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyText.labelSmall!.copyWith(
                            color: on ? p.brass : p.textFaint,
                            letterSpacing: 0,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                    ],
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
