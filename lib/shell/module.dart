import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import 'destination.dart';

enum Module {
  time([Destination.timer, Destination.history, Destination.statistics]),
  quests([Destination.quests, Destination.missions]),
  calendar([Destination.calendar]),
  notes([Destination.notes]),
  settings([Destination.settings]);

  const Module(this.pages);

  final List<Destination> pages;

  static const launchable = [time, quests, calendar, notes];

  String get icon => pages.first.icon;

  String label(AppLocalizations strings) => pages.first.label(strings);
}

@immutable
class ShellLocation {
  ShellLocation({
    required this.module,
    required Map<Module, Destination> pageOf,
    this.previous,
  }) : pageOf = Map.unmodifiable(pageOf);

  factory ShellLocation.initial() => ShellLocation.at(Destination.timer);

  factory ShellLocation.at(Destination destination) => ShellLocation(
    module: destination.module,
    pageOf: {destination.module: destination},
  );

  final Module module;
  final Map<Module, Destination> pageOf;
  final Module? previous;

  Destination get destination => pageOf[module] ?? module.pages.first;

  ShellLocation show(Destination destination) {
    final target = destination.module;
    if (destination == this.destination) return this;
    return ShellLocation(
      module: target,
      pageOf: {...pageOf, target: destination},
      previous: target == module ? previous : module,
    );
  }

  ShellLocation switchTo(Module target) =>
      show(pageOf[target] ?? target.pages.first);

  ShellLocation back() => previous == null ? this : switchTo(previous!);
}
