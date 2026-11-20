import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/event_type.dart';
import '../data/calendar_filter_store.dart';
import '../../quests/services/providers.dart';
import 'calendar_service.dart';
import '../../database/providers.dart';
import '../../core/clock_provider.dart';

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => CalendarService(
    ref.watch(databaseProvider),
    ref.watch(xpEngineProvider),
    ref.watch(clockProvider),
  ),
);

/// Where the Type_Filter is remembered; `main` swaps in the file store.
final calendarFilterStoreProvider = Provider<CalendarFilterStore>(
  (ref) => MemoryCalendarFilterStore(),
);

/// The filter read at startup, so the first frame already respects it.
final initialCalendarFilterProvider = Provider<Set<EventType>>(
  (ref) => EventType.values.toSet(),
);
