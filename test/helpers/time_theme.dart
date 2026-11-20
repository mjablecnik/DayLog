import 'package:flutter/material.dart';
import 'package:zafling/theme/quest_theme.dart';
import 'package:zafling/theme/tokens.dart';
import 'package:zafling/time_tracking/theme/time_theme.dart';

/// The time tracking colours of the dark blue theme, as the tests' fixed theme.
final AppThemeData testTimeTheme = AppThemeData.fromPalette(QuestPalette.guildBoard);

/// The Material theme of the app, so `context.palette` works in a test app.
ThemeData testMaterialTheme() => buildTheme(palette: QuestPalette.guildBoard);
