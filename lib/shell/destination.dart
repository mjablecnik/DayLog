import '../l10n/app_localizations.dart';
import '../ui_kit/common/app_icon.dart';

/// Where a Destination is listed in the Drawer: Time and Planning have a
/// heading, the app group (Settings) stands last without one.
enum DestinationGroup { time, planning, app }

/// A page of the app. The order of the values is the order of the pages in the
/// shell's `IndexedStack`; the Bottom_Bar shows the tabs in the order of
/// [Destination.tabs].
enum Destination {
  timer,
  history,
  statistics,
  quests,
  missions,
  calendar,
  notes,
  settings;

  /// The five tabs of the Bottom_Bar, left to right.
  static const List<Destination> tabs = <Destination>[
    timer,
    quests,
    calendar,
    notes,
    settings,
  ];

  /// The Destinations listed in the Drawer: the complete navigation, the tabs
  /// included, in the order of [DestinationGroup].
  static List<Destination> get drawerItems => <Destination>[
    for (final DestinationGroup g in DestinationGroup.values)
      for (final Destination d in values)
        if (d.group == g) d,
  ];

  bool get isTab => tabs.contains(this);

  /// The tab the Bottom_Bar marks while this Destination is shown.
  Destination get tab => switch (this) {
    history || statistics => timer,
    missions => quests,
    _ => this,
  };

  /// The group of the Destination in the Drawer.
  DestinationGroup get group => switch (this) {
    timer || history || statistics => DestinationGroup.time,
    quests || missions || calendar || notes => DestinationGroup.planning,
    settings => DestinationGroup.app,
  };

  /// The name in a `daylog://<name>` link.
  String get linkName => name;

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
