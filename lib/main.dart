import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/clock.dart';
import 'core/font_licenses.dart';
import 'calendar/data/calendar_filter_store.dart';
import 'database/app_database.dart';
import 'calendar/services/calendar_providers.dart';
import 'quests/services/providers.dart';
import 'shell/deep_link.dart';

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
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(const SystemClock()),
        calendarFilterStoreProvider.overrideWithValue(calendarFilterStore),
        initialCalendarFilterProvider.overrideWithValue(calendarFilter),
        deepLinksProvider.overrideWithValue(appLinksStream()),
      ],
      child: const ZaflingApp(),
    ),
  );
}
