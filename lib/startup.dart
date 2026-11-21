import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'calendar/data/calendar_filter_store.dart';
import 'calendar/services/calendar_providers.dart';
import 'core/clock.dart';
import 'core/clock_provider.dart';
import 'database/app_database.dart';
import 'database/import/database_importer.dart';
import 'database/import/import_providers.dart';
import 'database/import/preferences_writer.dart';
import 'database/providers.dart';
import 'settings/settings_loader.dart';
import 'settings/ui_providers.dart';
import 'shell/deep_link.dart';
import 'time_tracking/time_tracking.dart';

/// Starts the time tracking feature: it gets the container and a function that
/// completes once the app settings are loaded.
typedef TimeTrackingStarter =
    Future<void> Function(
      ProviderContainer container,
      Future<void> Function() settingsReady,
    );

Future<void> _startTimeTracking(
  ProviderContainer container,
  Future<void> Function() settingsReady,
) => TimeTrackingBootstrap(container).start(settingsReady: settingsReady);

/// Everything the app does before the first frame, with the parts that touch
/// the device passed in: the Database, the folder of the app files, the deep
/// links and the time tracking startup. `main` passes the real ones, the
/// startup test passes fakes. Returns the root widget for `runApp`.
Future<Widget> buildApp({
  required AppDatabase database,
  required Directory documentsDirectory,
  required Stream<Uri> deepLinks,
  TimeTrackingStarter startTimeTracking = _startTimeTracking,
}) async {
  final calendarFilterStore = FileCalendarFilterStore(
    File(p.join(documentsDirectory.path, 'calendar_filter.txt')),
  );
  final calendarFilter = await calendarFilterStore.load();
  late final ProviderContainer container;
  container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(const SystemClock()),
      calendarFilterStoreProvider.overrideWithValue(calendarFilterStore),
      initialCalendarFilterProvider.overrideWithValue(calendarFilter),
      deepLinksProvider.overrideWithValue(deepLinks),
      // One language for the whole app: the notification texts of the time
      // tracking feature follow the setting, they do not keep their own.
      timeLocaleProvider.overrideWith(
        (ref) => ref.watch(effectiveLocaleProvider),
      ),
      // What an import does beyond the tables: write the preferences, then let
      // the time tracking feature read them and re-schedule its notifications.
      importHooksProvider.overrideWithValue(
        ImportHooks(
          writePreferences: (Map<String, Object?> values) async =>
              writePreferences(await SharedPreferences.getInstance(), values),
          afterImport: () =>
              TimeTrackingBootstrap(container).refreshAfterImport(),
        ),
      ),
    ],
  );
  try {
    await startTimeTracking(container, () => loadSettings(container));
  } catch (error, stack) {
    // A failing reminder or notification setup must not keep the rest of the
    // app (quests, calendar, notes) from starting.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'time tracking startup',
      ),
    );
  }
  return UncontrolledProviderScope(
    container: container,
    child: const DayLogApp(),
  );
}
