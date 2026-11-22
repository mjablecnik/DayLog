import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/app_segmented.dart';
import '../../ui_kit/common/settings_group.dart';
import '../../ui_kit/layout/grouped_list.dart';

class ExperimentsGroup extends ConsumerWidget {
  const ExperimentsGroup({super.key});

  static const _weights = [
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final prefs = ref.watch(uiPreferencesProvider);
    final notifier = ref.read(uiPreferencesProvider.notifier);

    return SettingsGroup(
      label: strings.settings_groupExperiments,
      child: GroupedList(
        children: [
          ListRow(
            title: strings.settings_moduleButtonSide,
            trailing: SizedBox(
              width: Metrics.settingsControlWidth,
              child: AppSegmented<ModuleButtonSide>(
                options: [
                  SegmentedOption(
                    value: ModuleButtonSide.left,
                    label: strings.settings_moduleButtonLeft,
                  ),
                  SegmentedOption(
                    value: ModuleButtonSide.right,
                    label: strings.settings_moduleButtonRight,
                  ),
                ],
                selected: prefs.moduleButtonSide,
                onChanged: notifier.setModuleButtonSide,
              ),
            ),
          ),
          ListRow(
            title: strings.settings_drawerEnabled,
            trailing: Switch(
              value: prefs.drawerEnabled,
              onChanged: notifier.setDrawerEnabled,
            ),
          ),
          ListRow(
            title: strings.settings_titleWeight,
            trailing: SizedBox(
              width: Metrics.weightControlWidth,
              child: AppSegmented<FontWeight>(
                options: [
                  for (final weight in _weights)
                    SegmentedOption(value: weight, label: '${weight.value}'),
                ],
                selected: prefs.titleWeight,
                onChanged: notifier.setTitleWeight,
              ),
            ),
          ),
          ListRow(
            title: strings.settings_historyTagStyle,
            trailing: SizedBox(
              width: Metrics.weightControlWidth,
              child: AppSegmented<HistoryTagStyle>(
                options: [
                  SegmentedOption(
                    value: HistoryTagStyle.pill,
                    label: strings.settings_historyTagPill,
                  ),
                  SegmentedOption(
                    value: HistoryTagStyle.smallPill,
                    label: strings.settings_historyTagSmall,
                  ),
                  SegmentedOption(
                    value: HistoryTagStyle.dotText,
                    label: strings.settings_historyTagDot,
                  ),
                  SegmentedOption(
                    value: HistoryTagStyle.colorText,
                    label: strings.settings_historyTagText,
                  ),
                ],
                selected: prefs.historyTagStyle,
                onChanged: notifier.setHistoryTagStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
