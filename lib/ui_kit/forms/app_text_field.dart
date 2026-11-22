import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// The Form_Field for typed text: `card` fill, hairline border, a 2 pt brass
/// border while focused, an optional label above the value inside the box and
/// the length counter inside the box at the bottom right.
///
/// All decoration comes from the theme's `inputDecorationTheme`; only the
/// invalid state (a destructive border and a message below) is added here.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.label,
    this.errorText,
    this.multiline = false,
    this.autofocus = false,
    this.title = false,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.fieldKey,
    this.onFocusChange,
    this.prefix,
    this.focusNode,
    this.suffix,
    this.invalid = false,
    this.enforceMaxLength = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  /// Small label above the value, inside the box.
  final String? label;
  final String? errorText;
  final bool multiline;
  final bool autofocus;

  /// A larger, bolder field for a name.
  final bool title;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Longest text the field accepts; null for no limit. The counter shows
  /// inside the box.
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Key? fieldKey;
  final ValueChanged<bool>? onFocusChange;

  /// Widget before the text, for example a search icon.
  final Widget? prefix;
  final FocusNode? focusNode;

  /// Widget after the text, inside the box.
  final Widget? suffix;

  /// Draws the invalid border without a message below.
  final bool invalid;

  /// Stops typing at [maxLength]. Off where a validator reports the overflow.
  final bool enforceMaxLength;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final InputDecorationThemeData theme = Theme.of(context).inputDecorationTheme;
    final bool hasError = errorText != null || invalid;
    final TextStyle style =
        (title ? context.bodyText.titleMedium! : context.bodyText.bodyLarge!)
            .copyWith(color: p.text);
    final OutlineInputBorder base = theme.border! as OutlineInputBorder;
    OutlineInputBorder invalidBorder(double width) => base.copyWith(
      borderSide: BorderSide(color: p.destructive, width: width),
    );
    final bool counter = maxLength != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: onFocusChange,
          child: Stack(
            children: <Widget>[
              TextField(
                key: fieldKey,
                controller: controller,
                focusNode: focusNode,
                maxLength: maxLength,
                maxLengthEnforcement: enforceMaxLength
                    ? MaxLengthEnforcement.enforced
                    : MaxLengthEnforcement.none,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: textInputAction,
                textCapitalization: textCapitalization,
                keyboardType:
                    keyboardType ??
                    (multiline ? TextInputType.multiline : TextInputType.text),
                minLines: multiline ? 2 : 1,
                maxLines: multiline ? 5 : 1,
                cursorColor: p.brass,
                style: style,
                decoration: InputDecoration(
                  hintText: hint,
                  labelText: label,
                  counterText: '',
                  prefixIcon: prefix,
                  suffixIcon: suffix,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: EdgeInsets.fromLTRB(
                    Space.s14,
                    Space.s12,
                    Space.s14,
                    counter ? Space.s24 : Space.s12,
                  ),
                  enabledBorder: hasError ? invalidBorder(Metrics.hairline) : null,
                  focusedBorder: hasError
                      ? invalidBorder(Metrics.focusBorder)
                      : null,
                ),
              ),
              if (counter)
                Positioned(
                  right: Space.s14,
                  bottom: Space.s8,
                  child: IgnorePointer(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (BuildContext context, TextEditingValue v, _) =>
                          Text(
                            '${v.text.characters.length}/$maxLength',
                            style: context.bodyText.bodySmall!.copyWith(
                              color: p.textFaint,
                            ),
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.s4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText!,
                style: context.bodyText.bodySmall!.copyWith(
                  color: p.destructive,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
