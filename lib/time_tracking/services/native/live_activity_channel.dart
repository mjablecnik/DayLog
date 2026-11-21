import 'package:flutter/services.dart';

import '../../providers/app_settings_bridge.dart' show LocalizationsLoader;
import 'platform_channel.dart';

enum LiveActivityUpdate { paused, resumed, completed }

class LiveActivityChannel {
  LiveActivityChannel({required this._loadLocalizations});

  static const _channel = MethodChannel(PlatformChannels.liveActivity);

  /// The texts of the Live Activity come from the ARB files, in the language of
  /// the app, because the native view has no access to them.
  final LocalizationsLoader _loadLocalizations;

  Future<bool> startActivity({
    required DateTime endAt,
    required int totalSeconds,
  }) async {
    try {
      final l10n = await _loadLocalizations();
      final result = await _channel.invokeMethod<bool>('startLiveActivity', {
        'endAt': endAt.millisecondsSinceEpoch,
        'totalSeconds': totalSeconds,
        'completedText': l10n.time_liveActivityCompleted,
        'doneText': l10n.time_liveActivityDone,
        'pausedText': l10n.time_liveActivityPaused,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateActivity({
    required LiveActivityUpdate update,
    DateTime? endAt,
  }) async {
    final action = switch (update) {
      LiveActivityUpdate.paused => 'pause',
      LiveActivityUpdate.resumed => 'resume',
      LiveActivityUpdate.completed => 'complete',
    };
    try {
      final args = <String, dynamic>{'action': action};
      if (endAt != null) {
        args['endAt'] = endAt.millisecondsSinceEpoch;
      }
      await _channel.invokeMethod<void>('updateLiveActivity', args);
    } catch (_) {}
  }

  Future<void> endActivity() async {
    try {
      await _channel.invokeMethod<void>('endLiveActivity', {});
    } catch (_) {}
  }

  Future<bool> areActivitiesEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('areActivitiesEnabled', {});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  void setLockScreenActionHandler(void Function(String action, {int? endAtMs}) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLockScreenAction') {
        final args = call.arguments as Map?;
        final action = args?['action'] as String?;
        final endAtMs = args?['endAtMs'] as int?;
        if (action != null) handler(action, endAtMs: endAtMs);
      }
    });
  }
}
