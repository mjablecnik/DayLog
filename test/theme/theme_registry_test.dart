import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/theme/theme_registry.dart';
import 'package:daylog/theme/tokens.dart';

void main() {
  test('the registry holds the blue theme with its dark and light palettes', () {
    expect(themeRegistry, contains(blueTheme));
    expect(blueTheme.dark, AppPalette.guildBoard);
    expect(blueTheme.light, AppPalette.daylight);
    expect(blueTheme.dark.brightness, Brightness.dark);
    expect(blueTheme.light.brightness, Brightness.light);
  });

  test('every theme has a unique id and a name, and a light and a dark palette', () {
    expect(themeRegistry.map((ThemeDefinition t) => t.id).toSet(), hasLength(themeRegistry.length));
    for (final ThemeDefinition t in themeRegistry) {
      expect(t.id, isNotEmpty);
      expect(t.name, isNotEmpty);
      expect(t.light.isLight, isTrue, reason: t.id);
      expect(t.dark.isLight, isFalse, reason: t.id);
    }
  });

  test('an unknown id falls back to the first theme, a known one is found', () {
    expect(themeById('blue'), blueTheme);
    expect(themeById('no-such-theme'), themeRegistry.first);
  });

  test('the active theme is the blue one until a choice exists, and follows the id provider', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(activeThemeIdProvider), 'blue');
    expect(container.read(activeThemeProvider), blueTheme);

    final ProviderContainer other = ProviderContainer(
      overrides: [activeThemeIdProvider.overrideWithValue('blue')],
    );
    addTearDown(other.dispose);
    expect(other.read(activeThemeProvider), blueTheme);
  });
}
