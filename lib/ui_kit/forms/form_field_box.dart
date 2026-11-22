import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

class FormFieldBox extends StatelessWidget {
  const FormFieldBox({
    super.key,
    this.label,
    this.value,
    this.placeholder,
    this.onTap,
    this.focused = false,
    this.trailing,
  });

  final String? label;
  final String? value;
  final String? placeholder;
  final VoidCallback? onTap;
  final bool focused;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.bodyText;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.field),
      side: BorderSide(
        color: focused ? palette.brass : palette.boardLine,
        width: focused ? Metrics.focusBorder : Metrics.hairline,
      ),
    );
    return Material(
      color: palette.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s14,
              vertical: Space.s10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (label case final fieldLabel?)
                        Text(
                          fieldLabel,
                          style: text.bodySmall?.copyWith(
                            color: palette.textFaint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        value ?? placeholder ?? '',
                        style: text.titleMedium?.copyWith(
                          fontSize: value == null ? 16 : 17,
                          color: value == null
                              ? palette.textFaint
                              : palette.text,
                          fontWeight: value == null
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing case final widget?) ...[
                  const SizedBox(width: Space.s8),
                  widget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
