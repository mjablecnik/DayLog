import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/alarm_service.dart';
import 'app_settings_bridge.dart';
import '../services/native/live_activity_channel.dart';
import '../services/notification_service.dart';
import '../services/timer_service.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final service = AlarmService();
  ref.onDispose(service.dispose);
  return service;
});

final liveActivityChannelProvider = Provider<LiveActivityChannel>((ref) {
  return LiveActivityChannel(
    loadLocalizations: ref.watch(localizationsLoaderProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    loadLocalizations: ref.watch(localizationsLoaderProvider),
  );
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final alarm = ref.watch(alarmServiceProvider);
  final liveActivity = ref.watch(liveActivityChannelProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TimerNotifier(alarm, liveActivity, notifications);
});
