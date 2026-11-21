import 'package:daylog/time_tracking/providers/reminder_provider.dart';
import 'package:daylog/time_tracking/services/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReminderService extends ReminderService {
  int cancelCalls = 0;

  @override
  Future<void> cancelLegacyDailyReminder() async {
    cancelCalls++;
  }
}

void main() {
  test('the leftovers of the daily reminder are cancelled and their preferences removed', () async {
    SharedPreferences.setMockInitialValues({
      'reminder_enabled': true,
      'reminder_hour': 7,
      'reminder_minute': 30,
      'app_language': 'cs',
    });
    final service = _FakeReminderService();

    await removeLegacyDailyReminder(service);

    final prefs = await SharedPreferences.getInstance();
    expect(service.cancelCalls, 1);
    expect(prefs.containsKey('reminder_enabled'), isFalse);
    expect(prefs.containsKey('reminder_hour'), isFalse);
    expect(prefs.containsKey('reminder_minute'), isFalse);
    // Nothing else is touched.
    expect(prefs.getString('app_language'), 'cs');
  });
}
