import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/time_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/common/menu_button.dart' show ShellMenuScope;
import '../../../ui_kit/common/screen_header.dart';
import '../../providers/history_provider.dart';
import '../widgets/controls/day_navigator.dart';
import '../widgets/cards/day_summary.dart';
import '../widgets/cards/empty_state.dart';
import '../widgets/cards/history_entry_card.dart';
import '../widgets/sheets/manual_entry_sheet.dart';

const _swipeVelocityThreshold = 300.0;

bool _isToday(DateTime day) {
  final now = DateTime.now();
  final today = logicalDay(now);
  return day.year == today.year && day.month == today.month && day.day == today.day;
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _addEntry(BuildContext context, AppThemeData theme, DateTime selectedDay) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualEntrySheet(
        theme: theme,
        selectedDay: selectedDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(dayEntriesProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        // The tab bar below already clears the bottom inset.
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              onBack: () => ShellMenuScope.maybeOf(context)?.openPage?.call('timer'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.time_historyTitle,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: theme.text),
                    onPressed: () => _addEntry(context, theme, selectedDay),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            DayNavigator(theme: theme),
            const SizedBox(height: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() < _swipeVelocityThreshold) return;
                  if (velocity < 0) {
                    // Swipe left → next day
                    if (_isToday(selectedDay)) return;
                    ref.read(selectedDayProvider.notifier).state =
                        selectedDay.add(const Duration(days: 1));
                  } else {
                    // Swipe right → previous day
                    ref.read(selectedDayProvider.notifier).state =
                        selectedDay.subtract(const Duration(days: 1));
                  }
                },
                child: entriesAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return EmptyState(theme: theme);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DaySummary(entries: entries, theme: theme),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: entries.length,
                            itemBuilder: (context, index) => HistoryEntryCard(
                              entry: entries[index],
                              theme: theme,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(color: theme.accent),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      l10n.time_historyLoadError,
                      style: TextStyle(color: theme.dim),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
