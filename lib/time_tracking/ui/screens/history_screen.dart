import 'package:flutter/material.dart';

import '../../../ui_kit/sheet/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/clock_provider.dart';
import '../../../database/app_database.dart';
import '../../../ui_kit/sheet/confirm_destructive.dart';
import '../../providers/database_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/layout/grouped_list.dart';

import '../../theme/time_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/app_header.dart';
import '../../../ui_kit/layout/header_action.dart';
import '../../providers/history_provider.dart';
import '../widgets/controls/day_navigator.dart';
import '../widgets/cards/day_summary.dart';
import '../widgets/cards/empty_state.dart';
import '../widgets/cards/history_row.dart';
import '../widgets/sheets/edit_sheet.dart';
import '../widgets/sheets/manual_entry_sheet.dart';

const _swipeVelocityThreshold = 300.0;

bool _isToday(DateTime day, DateTime now) {
  final today = logicalDay(now);
  return day.year == today.year && day.month == today.month && day.day == today.day;
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _addEntry(BuildContext context, AppThemeData theme, DateTime selectedDay) {
    showAppSheet<void>(
      context,
      builder: (_) => ManualEntrySheet(
        theme: theme,
        selectedDay: selectedDay,
      ),
    );
  }

  void _edit(BuildContext context, AppThemeData theme, TimeEntry entry) {
    showAppSheet<void>(
      context,
      builder: (_) => EditSheet(theme: theme, entry: entry),
    );
  }

  Future<String?> _delete(
    BuildContext context,
    WidgetRef ref,
    TimeEntry entry,
  ) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: strings.time_historyDeleteEntryTitle,
      body: strings.time_historyDeleteEntryBody,
      confirmLabel: strings.time_commonDelete,
    );
    if (!confirmed || !context.mounted) return null;

    try {
      final database = ref.read(databaseServiceProvider).value;
      if (database == null) return strings.time_historyDbUnavailableShort;
      await database.deleteEntry(entry.id);
      return null;
    } catch (_) {
      return strings.time_historyDeleteEntryFailed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppThemeData.of(context);
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(dayEntriesProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final clock = ref.watch(clockProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        // The tab bar below already clears the bottom inset.
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              title: l10n.time_historyTitle,
              trailing: [
                HeaderAction(
                  icon: IconAsset.plus,
                  semanticLabel: l10n.time_manualEntryTitle,
                  onPressed: () => _addEntry(context, theme, selectedDay),
                ),
              ],
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
                    if (_isToday(selectedDay, clock.now())) return;
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
                          child: SlidableAutoCloseBehavior(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                Space.s16, Space.s8, Space.s16, Space.s16,
                              ),
                              children: [
                                GroupedList(
                                  children: [
                                    for (final entry in entries)
                                      HistoryRow(
                                        key: ValueKey(entry.id),
                                        entry: entry,
                                        theme: theme,
                                        onEdit: () => _edit(context, theme, entry),
                                        onDelete: () => _delete(context, ref, entry),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: Space.s12),
                                Text(
                                  l10n.time_historySwipeHint,
                                  textAlign: TextAlign.center,
                                  style: context.bodyText.bodySmall?.copyWith(
                                    color: context.palette.textFaint,
                                  ),
                                ),
                              ],
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
