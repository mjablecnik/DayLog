import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/shell/deep_link.dart';
import 'package:daylog/shell/destination.dart';
import 'package:daylog/shell/module.dart';

void main() {
  test('every destination appears in exactly one module', () {
    final pages = Module.values.expand((module) => module.pages).toList();
    expect(pages, unorderedEquals(Destination.values));
    for (final module in Module.values) {
      expect(module.pages.every((page) => page.module == module), isTrue);
    }
  });

  test('switching restores the page and toggles the previous module', () {
    final location = ShellLocation.initial()
        .show(Destination.history)
        .show(Destination.missions)
        .switchTo(Module.calendar);
    expect(location.destination, Destination.calendar);
    expect(location.back().destination, Destination.missions);
    expect(location.back().back().destination, Destination.calendar);
    expect(location.switchTo(Module.time).destination, Destination.history);
    expect(location.switchTo(Module.calendar), same(location));
  });

  test('daylog://<name> opens each Destination, in any letter case and with a path form', () {
    for (final Destination d in Destination.values) {
      expect(destinationFromUri(Uri.parse('daylog://${d.linkName}')), d);
      expect(destinationFromUri(Uri.parse('daylog://${d.linkName.toUpperCase()}')), d);
      expect(destinationFromUri(Uri.parse('daylog:///${d.linkName}')), d);
    }
  });

  // Feature: app-foundation, Property 2: Foreign links are ignored
  test('other schemes, unknown hosts and the Live Activity action links are ignored', () {
    for (final String link in <String>[
      'questlog://calendar',
      'timelogapp://timer',
      'https://calendar',
      'daylog://nowhere',
      'daylog://action/stop',
      'daylog://',
    ]) {
      expect(destinationFromUri(Uri.parse(link)), isNull, reason: link);
    }
  });
}
