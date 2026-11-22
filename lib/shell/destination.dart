import '../l10n/app_localizations.dart';
import '../ui_kit/common/app_icon.dart';
import 'module.dart';

/// A location in the shell and the target of a DayLog deep link.
enum Destination {
  timer,
  history,
  statistics,
  quests,
  missions,
  calendar,
  notes,
  settings;

  /// The name in a `daylog://<name>` link.
  String get linkName => name;

  Module get module => Module.values.firstWhere(
    (module) => module.pages.contains(this),
  );

  String get icon => switch (this) {
    timer => IconAsset.timer,
    history => IconAsset.history,
    statistics => IconAsset.statistics,
    quests => IconAsset.quests,
    missions => IconAsset.missions,
    calendar => IconAsset.calendar,
    notes => IconAsset.notes,
    settings => IconAsset.gear,
  };

  String label(AppLocalizations l) => switch (this) {
    timer => l.shell_tabTimer,
    history => l.shell_destinationHistory,
    statistics => l.shell_destinationStatistics,
    quests => l.app_tabQuests,
    missions => l.app_tabMissions,
    calendar => l.app_tabCalendar,
    notes => l.app_tabNotes,
    settings => l.app_tabSettings,
  };
}
