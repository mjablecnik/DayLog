import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bootstrap.dart' show kPendingReminderIdKey;
import '../../providers/recurring_reminders_provider.dart';
import '../../providers/reminder_action_provider.dart';
import 'reminder_action_screen.dart';

/// Opens the [ReminderActionScreen] when a reminder notification was tapped:
/// right away when the provider is set, after a cold start, and on return from
/// the background when the tap was stored while the app was suspended. Also
/// reschedules the recurring reminders on every return, so slots beyond the
/// original lookahead window get scheduled.
class ReminderActionHost extends ConsumerStatefulWidget {
  const ReminderActionHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderActionHost> createState() => _ReminderActionHostState();
}

class _ReminderActionHostState extends ConsumerState<ReminderActionHost> with WidgetsBindingObserver {
  bool _reminderActionOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The provider may have been set before this widget was mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _consumePendingReminder();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPersistedPendingReminder();
      ref.read(recurringReminderServiceProvider).rescheduleAll();
    }
  }

  Future<void> _checkPersistedPendingReminder() async {
    if (_reminderActionOpen) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final reminderId = prefs.getInt(kPendingReminderIdKey);
    if (reminderId != null) {
      await prefs.remove(kPendingReminderIdKey);
      if (mounted) _openReminderAction(reminderId);
    }
  }

  void _consumePendingReminder() {
    if (_reminderActionOpen) return;
    final pendingId = ref.read(pendingReminderActionProvider);
    if (pendingId != null) {
      ref.read(pendingReminderActionProvider.notifier).state = null;
      _openReminderAction(pendingId);
    }
  }

  void _openReminderAction(int reminderId) {
    if (_reminderActionOpen) return;
    _reminderActionOpen = true;
    // Clear the stored tap and the provider, so it cannot trigger twice.
    ref.read(pendingReminderActionProvider.notifier).state = null;
    SharedPreferences.getInstance().then((prefs) => prefs.remove(kPendingReminderIdKey));

    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => ReminderActionScreen(reminderId: reminderId)))
        .then((_) => _reminderActionOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(pendingReminderActionProvider, (prev, next) {
      if (next != null && !_reminderActionOpen) {
        ref.read(pendingReminderActionProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openReminderAction(next);
        });
      }
    });
    return widget.child;
  }
}
