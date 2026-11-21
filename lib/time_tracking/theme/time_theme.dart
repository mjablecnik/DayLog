import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// The colours the time tracking widgets read, derived from the app palette so
/// that they follow the active theme in its light and dark variant. The widgets
/// keep these names (they were TimeLog's own palette); each is one role of the
/// app palette.
@immutable
class AppThemeData {
  const AppThemeData({
    required this.isDark,
    required this.background,
    required this.text,
    required this.accent,
    required this.ink,
    required this.panel,
    required this.border,
    required this.track,
    required this.dim,
    required this.faint,
    required this.glow,
    required this.glowSoft,
  });

  /// The colours of [palette].
  factory AppThemeData.fromPalette(AppPalette palette) {
    return AppThemeData(
      isDark: !palette.isLight,
      background: palette.board,
      text: palette.text,
      accent: palette.brassText,
      ink: palette.inkOnBrass,
      panel: palette.field,
      border: palette.boardLine,
      track: palette.field,
      dim: palette.textDim,
      faint: palette.textFaint,
      glow: palette.brass.withAlpha(_glowAlpha),
      glowSoft: palette.brass.withAlpha(_glowSoftAlpha),
    );
  }

  /// The colours of the theme in effect at [context].
  static AppThemeData of(BuildContext context) => AppThemeData.fromPalette(context.palette);

  static const int _glowAlpha = 0x80;
  static const int _glowSoftAlpha = 0x99;

  /// True in the dark variant; the activity colours depend on it.
  final bool isDark;
  final Color background;
  final Color text;
  final Color accent;
  final Color ink;
  final Color panel;
  final Color border;
  final Color track;
  final Color dim;
  final Color faint;
  final Color glow;
  final Color glowSoft;
}
