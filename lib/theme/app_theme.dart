import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Carries the palette and both text roles next to [ThemeData].
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.palette,
    required this.display,
    required this.body,
  });

  final AppPalette palette;

  /// Titles and XP figures (switchable face).
  final TextTheme display;

  /// Running text, always Figtree.
  final TextTheme body;

  @override
  AppStyle copyWith({
    AppPalette? palette,
    TextTheme? display,
    TextTheme? body,
  }) => AppStyle(
    palette: palette ?? this.palette,
    display: display ?? this.display,
    body: body ?? this.body,
  );

  /// Palettes and text roles are discrete choices, so they switch at the end.
  @override
  AppStyle lerp(ThemeExtension<AppStyle>? other, double t) {
    if (other is! AppStyle) return this;
    return t < 0.5 ? this : other;
  }
}

/// Shorthand for widgets; names are shared by the whole UI layer.
extension AppContext on BuildContext {
  AppStyle get _style => Theme.of(this).extension<AppStyle>()!;

  AppPalette get palette => _style.palette;

  TextTheme get displayText => _style.display;

  TextTheme get bodyText => _style.body;
}

/// Material 3 theme for one palette; every text is Figtree.
ThemeData buildTheme({
  required AppPalette palette,
  FontWeight titleWeight = defaultTitleWeight,
}) {
  final AppPalette p = palette;
  final TextTheme display = buildDisplayTextTheme(p, titleWeight: titleWeight);
  final TextTheme body = buildBodyTextTheme(p);

  final ColorScheme scheme = ColorScheme(
    brightness: p.brightness,
    primary: p.brass,
    onPrimary: p.inkOnBrass,
    secondary: p.brass,
    onSecondary: p.inkOnBrass,
    error: p.destructive,
    onError: p.inkOnDestructive,
    surface: p.board,
    onSurface: p.text,
    surfaceContainerHighest: p.boardRaised,
    outline: p.boardLine,
    outlineVariant: p.boardLine,
    scrim: p.scrim,
  );

  // Taps leave no splash, highlight or hover tint anywhere: selection and
  // in-place fills show state. Only keyboard focus is painted.
  final Color focusFill = p.brassSoft;
  // Transparent rather than null: a null resolves to the Material 3 default
  // state layer, which tints a pressed button.
  final WidgetStateProperty<Color?> overlay =
      WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => states.contains(WidgetState.focused)
            ? focusFill
            : Colors.transparent,
      );

  const PageTransitionsTheme transitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
    },
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.field),
    borderSide: BorderSide(color: p.boardLine, width: Metrics.hairline),
  );
  final pickerShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.dialog),
  );
  final pickerSelection = WidgetStateProperty.resolveWith<Color?>(
    (states) => states.contains(WidgetState.selected) ? p.brass : null,
  );
  final pickerText = WidgetStateProperty.resolveWith<Color?>(
    (states) => states.contains(WidgetState.disabled)
        ? p.textFaint
        : states.contains(WidgetState.selected)
        ? p.inkOnBrass
        : p.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.board,
    canvasColor: p.board,
    fontFamily: bodyFamilyName,
    textTheme: body,
    primaryTextTheme: body,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: focusFill,
    dividerColor: p.boardLine,
    pageTransitionsTheme: transitions,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.brass,
      selectionColor: p.brass.withValues(alpha: 0.35),
      selectionHandleColor: p.brass,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      contentPadding: const EdgeInsets.symmetric(
        vertical: Space.s10,
        horizontal: Space.s14,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.brass, width: Metrics.focusBorder),
      ),
      hintStyle: body.titleMedium?.copyWith(
        color: p.textFaint,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: body.bodySmall?.copyWith(
        color: p.textFaint,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: body.bodySmall?.copyWith(
        color: p.textFaint,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.sheet,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: p.brass,
      headerForegroundColor: p.inkOnBrass,
      dayForegroundColor: pickerText,
      dayBackgroundColor: pickerSelection,
      yearForegroundColor: pickerText,
      yearBackgroundColor: pickerSelection,
      weekdayStyle: body.bodySmall?.copyWith(color: p.textDim),
      shape: pickerShape,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.sheet,
      hourMinuteColor: WidgetStateColor.resolveWith(
        (states) => pickerSelection.resolve(states) ?? p.tone,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => pickerText.resolve(states) ?? p.text,
      ),
      dialHandColor: p.brass,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => pickerText.resolve(states) ?? p.text,
      ),
      helpTextStyle: body.labelLarge?.copyWith(color: p.textDim),
      shape: pickerShape,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.sheet,
      modalBackgroundColor: p.sheet,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Radii.sheetTop),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.sheet,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: display.titleLarge,
      contentTextStyle: body.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.dialog),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.boardRaised,
      contentTextStyle: body.bodyMedium,
      actionTextColor: p.brass,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(overlayColor: overlay),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(overlayColor: overlay),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(overlayColor: overlay),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        overlayColor: overlay,
        backgroundColor: WidgetStatePropertyAll<Color>(p.brass),
        foregroundColor: WidgetStatePropertyAll<Color>(p.inkOnBrass),
        textStyle: WidgetStatePropertyAll<TextStyle?>(body.labelLarge),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: p.boardLine,
      thickness: Metrics.hairline,
      space: Metrics.hairline,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppStyle(palette: p, display: display, body: body),
    ],
  );
}

/// Glow for primary controls and the timer arc.
abstract final class AppGlow {
  static List<BoxShadow> segment(AppPalette palette) => [
    BoxShadow(
      color: palette.text.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: palette.text.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> button(AppPalette palette) => <BoxShadow>[
    BoxShadow(
      color: palette.glowButton,
      blurRadius: palette.glowButtonBlur,
      offset: Offset(0, palette.glowButtonOffsetY),
    ),
  ];

  static Paint ring(AppPalette palette, {required double strokeWidth}) =>
      Paint()
        ..color = palette.glowRing
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, palette.glowRingBlur);
}
