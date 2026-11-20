import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'calendar/data/calendar_filter_store.dart';
import 'calendar/services/calendar_providers.dart';
import 'core/clock.dart';
import 'core/clock_provider.dart';
import 'core/font_licenses.dart';
import 'database/app_database.dart';
import 'database/providers.dart';
import 'quests/services/providers.dart' show settingsProvider;
import 'settings/ui_providers.dart';
import 'shell/deep_link.dart';
import 'time_tracking/time_tracking.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  // Opens the on-device file database lazily on first query.
  final database = AppDatabase();
  final directory = await getApplicationDocumentsDirectory();
  final calendarFilterStore = FileCalendarFilterStore(
    File(p.join(directory.path, 'calendar_filter.txt')),
  );
  final calendarFilter = await calendarFilterStore.load();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(const SystemClock()),
      calendarFilterStoreProvider.overrideWithValue(calendarFilterStore),
      initialCalendarFilterProvider.overrideWithValue(calendarFilter),
      deepLinksProvider.overrideWithValue(appLinksStream()),
      // One language for the whole app: the notification texts of the time
      // tracking feature follow the setting, they do not keep their own.
      timeLocaleProvider.overrideWith((ref) => ref.watch(effectiveLocaleProvider)),
    ],
  );
  try {
    await TimeTrackingBootstrap(container).start(
      settingsReady: () => container.read(settingsProvider.future),
    );
  } catch (error, stack) {
    // A failing reminder or notification setup must not keep the rest of the
    // app (quests, calendar, notes) from starting.
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack, library: 'time tracking startup'),
    );
  }
  runApp(UncontrolledProviderScope(container: container, child: const ZaflingApp()));
}
