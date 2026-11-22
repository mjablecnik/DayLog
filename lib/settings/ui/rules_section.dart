import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../quests/data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../quests/services/providers.dart';
import '../../ui_kit/forms/error_text.dart';
import '../../quests/ui/sheets/rule_sheet.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/haptics.dart';
import '../../ui_kit/common/snackbar_host.dart';
import '../../ui_kit/layout/grouped_list.dart';
import '../../ui_kit/sheet/confirm_destructive.dart';
import 'rule_row.dart';

/// Recurring rules group of the Settings_Screen (requirement 12): the header
/// with the active count, one row per rule, the add row and its hint. Draws
/// its own group header.
class RulesSection extends ConsumerWidget {
  const RulesSection({super.key});

  Future<void> _postNow(
    BuildContext context,
    WidgetRef ref,
    RuleSummary rule,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await confirmAction(
      context,
      title: rule.name,
      body: l.rule_addHint,
      confirmLabel: l.rule_postNow,
    );
    if (!confirmed || !context.mounted) return;
    unawaited(Haptics.light());
    try {
      final result = await ref.read(recurrenceServiceProvider).postNow(rule.id);
      if (!context.mounted) return;
      final notes = <String>[
        l.rule_postedMessage(result.mission.name),
        if (result.skippedNextPosting) l.rule_postedSkippedNote,
        if (result.closedPreviousInstance) l.rule_postedClosedNote,
      ];
      showAppSnack(context, notes.join(' '));
    } on DomainError catch (error) {
      if (!context.mounted) return;
      showAppSnack(context, domainErrorText(l, error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider).value ?? const <RuleSummary>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GroupedList(
          children: [
            for (final rule in rules)
              RuleRow(
                key: ValueKey<int>(rule.id),
                rule: rule,
                onEdit: () => showRuleSheet(context, editing: rule),
                onPostNow: () => _postNow(context, ref, rule),
              ),
            AddRuleRow(onTap: () => showRuleSheet(context)),
          ],
        ),
        const SizedBox(height: Space.s8),
        Text(
          l.rule_addHint,
          style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
        ),
      ],
    );
  }
}
