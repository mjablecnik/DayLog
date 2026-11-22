import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../quests/data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/layout/grouped_list.dart';
import '../../quests/ui/sheets/rule_sheet.dart' show ruleCadenceLabel;
import '../../ui_kit/controls/app_buttons.dart';
import '../../ui_kit/common/app_icon.dart';

/// One rule in the Settings list: tinted icon tile, name, a line with the
/// Cadence, quest count and Next_Occurrence, and the "Post now" pill.
///
/// Tapping the left part opens the rule for editing; the pill posts the rule
/// by hand. While an Instance is open the pill reads "Posted" and is dimmed,
/// but stays active: posting again closes the open Instance (requirement 12.4).
class RuleRow extends StatelessWidget {
  const RuleRow({
    super.key,
    required this.rule,
    required this.onEdit,
    required this.onPostNow,
  });

  final RuleSummary rule;
  final VoidCallback onEdit;
  final VoidCallback onPostNow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final line = l.rule_line(
      ruleCadenceLabel(l, rule.cadence),
      rule.quests.length,
      DateFormat.MMMd(l.localeName).format(rule.nextOccurrence),
    );

    return ListRow(
      title: rule.name,
      subtitle: line,
      leading: const IconTile(IconAsset.repeat),
      onTap: onEdit,
      trailing: Semantics(
        button: true,
        label: '${l.rule_postNow}: ${rule.name}',
        value: rule.hasOpenInstance ? l.rule_posted : null,
        excludeSemantics: true,
        onTap: onPostNow,
        child: Opacity(
          opacity: rule.hasOpenInstance ? 0.5 : 1,
          child: PillButton(
            label: rule.hasOpenInstance ? l.rule_posted : l.rule_postNow,
            onPressed: onPostNow,
          ),
        ),
      ),
    );
  }
}

class AddRuleRow extends StatelessWidget {
  const AddRuleRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      AddRow(label: AppLocalizations.of(context).rule_addRow, onTap: onTap);
}
