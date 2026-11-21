import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quests/data/models.dart';
import '../quests/services/providers.dart' show settingsProvider;

/// Waits until the app settings are read from the Database, for code that runs
/// before the first frame and has no widget to listen for them.
///
/// Riverpod 3 pauses a provider nobody listens to, so a bare
/// `container.read(settingsProvider.future)` never completes. The listener is
/// kept for the life of [container]; the app watches the settings anyway.
Future<AppSettings> loadSettings(ProviderContainer container) {
  container.listen<AsyncValue<AppSettings>>(
    settingsProvider,
    (AsyncValue<AppSettings>? _, AsyncValue<AppSettings> _) {},
  );
  return container.read(settingsProvider.future);
}
