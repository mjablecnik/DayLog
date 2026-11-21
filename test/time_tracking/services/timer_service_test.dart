import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daylog/l10n/app_localizations.dart';
import 'package:daylog/time_tracking/services/native/platform_channel.dart';
import 'package:daylog/time_tracking/services/alarm_service.dart';
import 'package:daylog/time_tracking/services/native/live_activity_channel.dart';
import 'package:daylog/time_tracking/services/notification_service.dart';
import 'package:daylog/time_tracking/services/timer_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    for (final channel in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      PlatformChannels.liveActivity,
      PlatformChannels.notifications,
    ]) {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (call) async => null,
      );
    }
  });

  TimerNotifier createNotifier() {
    Future<AppLocalizations> loader() async => lookupAppLocalizations(const Locale('en'));
    return TimerNotifier(
      AlarmService(),
      LiveActivityChannel(loadLocalizations: loader),
      NotificationService(loadLocalizations: loader),
    );
  }

  test('stop() clears logTrigger set by stopAndLog()', () async {
    final notifier = createNotifier();
    await Future<void>.delayed(Duration.zero);

    notifier.start();
    notifier.stopAndLog();
    expect(notifier.state.logTrigger, LogTrigger.stop);

    notifier.stop();
    expect(notifier.state.status, TimerStatus.idle);
    expect(notifier.state.logTrigger, isNull);
  });

  test('stop() clears logTrigger set by finishNow()', () async {
    final notifier = createNotifier();
    await Future<void>.delayed(Duration.zero);

    notifier.start();
    notifier.finishNow();
    expect(notifier.state.logTrigger, LogTrigger.finish);

    notifier.stop();
    expect(notifier.state.status, TimerStatus.idle);
    expect(notifier.state.logTrigger, isNull);
  });

}
