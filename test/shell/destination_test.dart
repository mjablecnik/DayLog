import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/shell/deep_link.dart';
import 'package:zafling/shell/destination.dart';

void main() {
  // Feature: app-foundation, Property 1: Every Destination is reachable
  test('every Destination is a tab or a Drawer item, never both and never neither', () {
    for (final Destination d in Destination.values) {
      expect(Destination.tabs.contains(d) != Destination.drawerItems.contains(d), isTrue, reason: d.name);
    }
    expect(Destination.tabs, <Destination>[
      Destination.timer,
      Destination.quests,
      Destination.calendar,
      Destination.notes,
      Destination.settings,
    ]);
  });

  test('the Bottom_Bar marks the tab a Drawer page belongs to', () {
    expect(Destination.history.tab, Destination.timer);
    expect(Destination.statistics.tab, Destination.timer);
    expect(Destination.missions.tab, Destination.quests);
    for (final Destination d in Destination.tabs) {
      expect(d.tab, d);
    }
    for (final Destination d in Destination.drawerItems) {
      expect(d.group, isNotNull, reason: d.name);
      expect(d.tab.isTab, isTrue, reason: d.name);
    }
  });

  test('zafling://<name> opens each Destination, in any letter case and with a path form', () {
    for (final Destination d in Destination.values) {
      expect(destinationFromUri(Uri.parse('zafling://${d.linkName}')), d);
      expect(destinationFromUri(Uri.parse('zafling://${d.linkName.toUpperCase()}')), d);
      expect(destinationFromUri(Uri.parse('zafling:///${d.linkName}')), d);
    }
  });

  // Feature: app-foundation, Property 2: Foreign links are ignored
  test('other schemes, unknown hosts and the Live Activity action links are ignored', () {
    for (final String link in <String>[
      'questlog://calendar',
      'timelogapp://timer',
      'https://calendar',
      'zafling://nowhere',
      'zafling://action/stop',
      'zafling://',
    ]) {
      expect(destinationFromUri(Uri.parse(link)), isNull, reason: link);
    }
  });
}
