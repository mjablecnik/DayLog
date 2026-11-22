import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/controls/app_buttons.dart';
import '../../../ui_kit/layout/app_header.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/time_theme.dart';
import '../../providers/reminder_action_provider.dart';
import 'reminder_settings_screen.dart';

/// Done/Snooze screen shown when the user taps a Recurring_Reminder
/// notification (Requirements 5.2, 5.3, 5.4, 5.5, 5.6, 6, 7, 12.3).
class ReminderActionScreen extends ConsumerStatefulWidget {
  final int reminderId;

  const ReminderActionScreen({super.key, required this.reminderId});

  @override
  ConsumerState<ReminderActionScreen> createState() =>
      _ReminderActionScreenState();
}

class _ReminderActionScreenState extends ConsumerState<ReminderActionScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: loading changes a provider, which Riverpod does
    // not allow while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    await ref.read(reminderActionProvider.notifier).load(widget.reminderId);
    if (mounted) setState(() => _loaded = true);
  }

  /// Closes this screen and returns to the page under it.
  void _dismiss() => Navigator.of(context).pop();

  Future<void> _handleDone() async {
    await ref.read(reminderActionProvider.notifier).markDone(widget.reminderId);
    if (!mounted) return;
    if (ref.read(reminderActionProvider).error == null) {
      _dismiss();
    }
  }

  Future<void> _handleSnooze() async {
    await ref.read(reminderActionProvider.notifier).snooze(widget.reminderId);
    if (mounted) _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(reminderActionProvider);

    if (!_loaded) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: CircularProgressIndicator(color: theme.accent)),
      );
    }

    if (state.reminder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()),
        );
      });
      return Scaffold(
        backgroundColor: theme.background,
        body: const SizedBox.shrink(),
      );
    }

    final reminder = state.reminder!;
    final description = reminder.description?.trim();

    String time(int minutes) =>
        '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: l10n.time_settingsRecurringRemindersLabel,
              leading: HeaderLeading.close,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Space.s24),
                  child: Column(
                    children: [
                      Text(
                        reminder.name,
                        textAlign: TextAlign.center,
                        style: context.displayText.displayMedium,
                      ),
                      const SizedBox(height: Space.s8),
                      Text(
                        l10n.time_reminderWindow(
                          time(reminder.startTime),
                          time(reminder.endTime),
                          reminder.repeatInterval,
                        ),
                        textAlign: TextAlign.center,
                        style: context.bodyText.bodyLarge?.copyWith(
                          color: context.palette.textDim,
                        ),
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: Space.s16),
                        Text(description, textAlign: TextAlign.center),
                      ],
                      if (state.error case final error?) ...[
                        const SizedBox(height: Space.s16),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.palette.destructiveText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.s24),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.tonal(
                      label: l10n.time_reminderSnooze,
                      onPressed: state.isLoading ? null : _handleSnooze,
                    ),
                  ),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: AppButton.primary(
                      label: l10n.time_reminderDone,
                      onPressed: state.isLoading ? null : _handleDone,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
