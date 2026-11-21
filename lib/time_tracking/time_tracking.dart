/// The public surface of the time tracking feature. The rest of the app imports
/// only this file: the three pages, the settings groups, the host that opens a
/// tapped reminder, the startup and the providers the app root overrides.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/statistics_provider.dart';

export 'bootstrap.dart' show TimeTrackingBootstrap;
export 'providers/app_settings_bridge.dart' show timeLocaleProvider;
export 'ui/screens/history_screen.dart' show HistoryScreen;
export 'ui/screens/reminder_action_host.dart' show ReminderActionHost;
export 'ui/screens/statistics_screen.dart' show StatisticsScreen;
export 'ui/screens/time_settings_groups.dart' show TimeSettingsGroups, TimeToolsGroup;
export 'ui/screens/timer_screen.dart' show TimerScreen;

/// Recomputes the statistics; the shell calls it when the Statistics page is
/// opened, so the figures are never stale.
void refreshStatistics(WidgetRef ref) => ref.invalidate(statisticsProvider);
