import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'recurring_reminder_service.dart' show recurringReminderBackgroundHandler;

/// Owns the `flutter_local_notifications` plugin: initialization, the
/// notification permission and the launch payload. Separate from
/// [NotificationService], which handles one-shot timer-completion alerts
/// through a native method channel.
class ReminderService {
  static const int notificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// The shared plugin instance, passed to [RecurringReminderService] so the
  /// whole app initializes `flutter_local_notifications` exactly once.
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Initialize the plugin. Must be called before any other method.
  /// [onNotificationTap] is invoked with the notification payload whenever
  /// the user taps a notification while the app is running.
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'DayLog',
      appUserModelId: 'com.jablecnik.daylog',
      guid: '74e61031-08fe-4096-b98c-24679542e64a',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          onNotificationTap(response.payload),
      onDidReceiveBackgroundNotificationResponse:
          recurringReminderBackgroundHandler,
    );
  }

  /// Request notification permission on iOS. Returns true if granted.
  Future<bool> requestPermission() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin == null) return true;
    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  /// Cancels the daily reminder that earlier versions could schedule. The
  /// feature is gone, but a notification scheduled by an older run would keep
  /// firing.
  Future<void> cancelLegacyDailyReminder() async {
    await _plugin.cancel(id: notificationId);
  }

  /// If the app was cold-launched by tapping the reminder notification,
  /// returns its payload; otherwise returns null.
  ///
  /// `flutter_local_notifications_linux` doesn't implement this call and
  /// throws [UnimplementedError] instead of returning null, so Linux is
  /// treated the same as "no launch payload".
  Future<String?> getLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
    } on UnimplementedError {
      // Not supported on this platform.
    }
    return null;
  }
}
