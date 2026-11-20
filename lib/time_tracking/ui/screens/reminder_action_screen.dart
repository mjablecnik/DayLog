import 'package:flutter/material.dart';
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
  ConsumerState<ReminderActionScreen> createState() => _ReminderActionScreenState();
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
      return Scaffold(backgroundColor: theme.background, body: const SizedBox.shrink());
    }

    final reminder = state.reminder!;
    final description = reminder.description?.trim();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Text(
                reminder.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.dim,
                    fontSize: 16,
                  ),
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 20),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(flex: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isLoading ? null : _handleSnooze,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.dim,
                        side: BorderSide(color: theme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        l10n.time_reminderSnooze,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: theme.ink,
                        disabledBackgroundColor: theme.accent.withValues(alpha: 0.3),
                        disabledForegroundColor: theme.ink.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: state.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: theme.ink,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.time_reminderDone,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
