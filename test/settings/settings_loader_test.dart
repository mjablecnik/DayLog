import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/database/preferences.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/quests/data/models.dart';
import 'package:daylog/quests/services/providers.dart' show settingsProvider;
import 'package:daylog/settings/settings_loader.dart';

import '../helpers/test_database.dart';

void main() {
  test('loadSettings completes before any widget listens, where a bare read waits forever', () async {
    final db = createTestDatabase();
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final AppSettings settings = await loadSettings(container).timeout(const Duration(seconds: 5));
    expect(settings.language, AppLanguage.system);
    expect(container.read(settingsProvider).hasValue, isTrue);
  });
}
