import 'package:flutter/material.dart';
import 'package:daylog/theme/app_theme.dart';
import 'package:daylog/theme/tokens.dart';
import 'package:daylog/time_tracking/theme/time_theme.dart';

/// The time tracking colours of the dark blue theme, as the tests' fixed theme.
final AppThemeData testTimeTheme = AppThemeData.fromPalette(AppPalette.guildBoard);

/// The Material theme of the app, so `context.palette` works in a test app.
ThemeData testMaterialTheme() => buildTheme(palette: AppPalette.guildBoard);
