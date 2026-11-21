import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tokens.dart';

/// One theme of the app: a light and a dark palette under one id. A screen never
/// names a theme; it reads `context.palette`, so adding a theme means adding a
/// [ThemeDefinition] to [themeRegistry] and nothing else.
@immutable
class ThemeDefinition {
  const ThemeDefinition({required this.id, required this.name, required this.light, required this.dark});

  /// Stable identifier, the value a stored theme choice will hold.
  final String id;

  /// Human-readable name, for the picker once there is more than one theme.
  final String name;
  final AppPalette light;
  final AppPalette dark;
}

/// The blue theme: dark `guildBoard` and light `daylight`.
const ThemeDefinition blueTheme = ThemeDefinition(
  id: 'blue',
  name: 'Blue',
  light: AppPalette.daylight,
  dark: AppPalette.guildBoard,
);

/// Every theme the app has.
const List<ThemeDefinition> themeRegistry = <ThemeDefinition>[blueTheme];

/// The theme with [id]; the first one when the id is unknown (a stored choice of
/// a theme that was removed).
ThemeDefinition themeById(String id) =>
    themeRegistry.firstWhere((ThemeDefinition t) => t.id == id, orElse: () => themeRegistry.first);

/// The id of the active theme. It is the blue one until the app lets the user
/// choose; the choice will be stored and read here.
final activeThemeIdProvider = Provider<String>((ref) => blueTheme.id);

/// The active theme.
final activeThemeProvider = Provider<ThemeDefinition>(
  (ref) => themeById(ref.watch(activeThemeIdProvider)),
);
