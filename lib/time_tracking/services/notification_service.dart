import 'package:flutter/services.dart';
import '../providers/app_settings_bridge.dart' show LocalizationsLoader;
import 'native/platform_channel.dart';

/// Schedules/cancels a native local notification for timer completion.
/// This ensures the alarm sound plays even when the app is in background.
class NotificationService {
  NotificationService({required this._loadLocalizations});

  /// The notification text comes from the ARB files, in the language of the app.
  final LocalizationsLoader _loadLocalizations;

  static const _channel = MethodChannel(PlatformChannels.notifications);

  /// Request notification permission (call once at app start).
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Schedule a notification to fire at [endAt].
  Future<void> scheduleTimerNotification({required DateTime endAt}) async {
    try {
      final l10n = await _loadLocalizations();
      await _channel.invokeMethod<void>('scheduleNotification', {
        'endAtMs': endAt.millisecondsSinceEpoch,
        'title': l10n.app_name,
        'body': l10n.time_timerCompleteNotificationBody,
      });
    } catch (_) {}
  }

  /// Cancel any pending timer notification (on pause/stop).
  Future<void> cancelTimerNotification() async {
    try {
      await _channel.invokeMethod<void>('cancelNotification');
    } catch (_) {}
  }
}
