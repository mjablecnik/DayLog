import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/calendar_providers.dart';
import '../widgets/event_task_card.dart';
import '../../../ui_kit/common/announce.dart';
import '../../../ui_kit/common/haptics.dart';
import '../../../ui_kit/common/snackbar_host.dart';
import '../../../quests/ui/state/quest_actions.dart';

/// Completes or reopens an Event_Task (the check tap on the Board), with the
/// same feedback as a Quest: a haptic tap and a screen-reader announcement on
/// completion, the withdrawal message on reopening. A failure leaves the card
/// as it was and shows an error message.
Future<void> toggleEventTask(
  BuildContext context,
  WidgetRef ref,
  EventOccurrence occurrence,
) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final service = ref.read(calendarServiceProvider);
  final CalendarEventKey key = (occurrence.event.id, occurrence.start);
  try {
    if (!occurrence.isCompleted) {
      final result = await service.completeOccurrence(key.$1, key.$2);
      if (!context.mounted) return;
      Haptics.success();
      final String text = l.a11y_eventCompleted(occurrence.event.name, result.awardedXp);
      announce(
        context,
        result.levelAfter > result.levelBefore ? '$text. ${l.a11y_levelUp(result.levelAfter)}' : text,
      );
    } else {
      final int xp = eventTaskXp(occurrence);
      await service.reopenOccurrence(key.$1, key.$2);
      if (!context.mounted) return;
      Haptics.light();
      showAppSnack(context, l.board_rewardWithdrawn(xp));
    }
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
  }
}

typedef CalendarEventKey = (int, DateTime);
