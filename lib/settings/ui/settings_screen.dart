import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../database/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../quests/services/providers.dart';
import '../../ui_kit/forms/error_text.dart';
import '../ui_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/app_icon.dart';
import '../../ui_kit/layout/app_header.dart';
import '../../ui_kit/layout/header_action.dart';
import '../../ui_kit/layout/grouped_list.dart';
import '../../ui_kit/common/settings_group.dart';
import '../../ui_kit/common/app_segmented.dart';
import '../../ui_kit/common/snackbar_host.dart';
import 'experiments_group.dart';
import 'export_row.dart';
import 'import_row.dart';
import 'hero_name_sheet.dart';
import 'rules_screen.dart';
import 'shortcut_guide.dart';
import 'shortcut_screen.dart';

/// The "Nastavení" tab: profile, language, appearance, recurring rules,
/// the Home Screen shortcut guide and About.
///
/// Every value is read from streams that already hold the stored settings, so
/// a change of language or theme repaints this screen in place: the list keeps
/// its scroll position and nothing falls back to a loading state.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    super.key,
    required this.shortcutTargets,
    this.moduleGroups = const <Widget>[],
  });

  /// The pages the Home Screen shortcut guide offers.
  final List<ShortcutTarget> shortcutTargets;

  /// Groups of the other features (for example the reminders), shown between
  /// the shortcut guide and the data group. The shell supplies them, so this
  /// screen does not know the features.
  final List<Widget> moduleGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        // The tab bar below already clears the bottom inset.
        bottom: false,
        child: Column(
          children: <Widget>[
            // Outside the list, so the menu button stays reachable when the
            // list is scrolled.
            AppHeader(title: l.settings_title),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s24,
                  Space.s20,
                  Space.s24,
                ),
                children: <Widget>[
                  const _HeroProfile(),
                  const SizedBox(height: Space.s24),
                  SettingsGroup(
                    label: l.settings_groupAppearanceLanguage,
                    child: GroupedList(
                      children: [
                        ListRow(
                          title: l.settings_groupLanguage,
                          leading: const IconTile(IconAsset.globe),
                          trailing: const SizedBox(
                            width: Metrics.settingsControlWidth,
                            child: _LanguageControl(),
                          ),
                        ),
                        ListRow(
                          title: l.settings_groupAppearance,
                          leading: const IconTile(IconAsset.contrast),
                          trailing: const SizedBox(
                            width: Metrics.settingsControlWidth,
                            child: _ThemeControl(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.s24),
                  SettingsGroup(
                    label: l.settings_groupPlanning,
                    child: GroupedList(
                      children: [const _RulesLink(), ...moduleGroups],
                    ),
                  ),
                  const SizedBox(height: Space.s24),
                  SettingsGroup(
                    label: l.settings_groupDeviceData,
                    child: GroupedList(
                      children: [
                        ListRow(
                          title: l.settings_shortcutTitle,
                          leading: const IconTile(IconAsset.smartphone),
                          showChevron: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ShortcutScreen(targets: shortcutTargets),
                            ),
                          ),
                        ),
                        const ExportRow(),
                        const ImportRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.s24),
                  const ExperimentsGroup(),
                  const SizedBox(height: Space.s24),
                  SettingsGroup(
                    label: l.settings_groupAbout,
                    child: const _AboutRow(),
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

/// Shows a localized message for a failed write; never exception text.
void _reportFailure(BuildContext context, Object error) {
  if (error is! DomainError) return;
  showAppSnack(context, domainErrorText(AppLocalizations.of(context), error));
}

class _LanguageControl extends ConsumerWidget {
  const _LanguageControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final effective = ref.watch(effectiveLocaleProvider).languageCode;
    return AppSegmented<AppLanguage>(
      options: <SegmentedOption<AppLanguage>>[
        SegmentedOption<AppLanguage>(
          value: AppLanguage.cs,
          label: l.settings_languageCsShort,
          semanticLabel: l.settings_languageCs,
        ),
        SegmentedOption<AppLanguage>(
          value: AppLanguage.en,
          label: l.settings_languageEnShort,
          semanticLabel: l.settings_languageEn,
        ),
      ],
      selected: effective == 'cs' ? AppLanguage.cs : AppLanguage.en,
      onChanged: (AppLanguage language) async {
        try {
          await ref.read(settingsServiceProvider).setLanguage(language);
        } catch (e) {
          if (!context.mounted) return;
          _reportFailure(context, e);
        }
      },
    );
  }
}

class _ThemeControl extends ConsumerWidget {
  const _ThemeControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stored = ref.watch(
      settingsProvider.select((s) => s.value?.theme ?? ThemeModeSetting.system),
    );
    return AppSegmented<ThemeModeSetting>(
      options: <SegmentedOption<ThemeModeSetting>>[
        SegmentedOption<ThemeModeSetting>(
          value: ThemeModeSetting.light,
          label: '',
          semanticLabel: l.settings_themeLight,
          icon: IconAsset.sun,
        ),
        SegmentedOption<ThemeModeSetting>(
          value: ThemeModeSetting.dark,
          label: '',
          semanticLabel: l.settings_themeDark,
          icon: IconAsset.moon,
        ),
        SegmentedOption<ThemeModeSetting>(
          value: ThemeModeSetting.system,
          label: '',
          semanticLabel: l.settings_themeSystem,
          icon: IconAsset.monitor,
        ),
      ],
      selected: stored,
      onChanged: (ThemeModeSetting theme) async {
        try {
          await ref.read(settingsServiceProvider).setTheme(theme);
        } catch (e) {
          if (!context.mounted) return;
          _reportFailure(context, e);
        }
      },
    );
  }
}

/// The licences row, and under it the application name and its version.
class _AboutRow extends ConsumerWidget {
  const _AboutRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final version = ref.watch(appVersionProvider).value;
    final style = context.bodyText.bodyMedium!.copyWith(
      color: context.palette.textFaint,
      fontSize: 13,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _LicensesRow(version: version),
        const SizedBox(height: Space.s8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l.app_name, style: style),
              if (version != null)
                Text(l.settings_version(version), style: style),
            ],
          ),
        ),
      ],
    );
  }
}

/// The row that opens the recurring Missions page, with the active count.
class _RulesLink extends ConsumerWidget {
  const _RulesLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final int count = ref.watch(rulesProvider).value?.length ?? 0;
    return ListRow(
      title: l.settings_groupRules,
      leading: const IconTile(IconAsset.repeat),
      value: l.settings_rulesActive(count),
      showChevron: true,
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const RulesScreen())),
    );
  }
}

/// Opens Flutter's licence page, which lists the framework, package and
/// bundled-font licences.
class _LicensesRow extends StatelessWidget {
  const _LicensesRow({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.settings_licenses,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: () {
          showLicensePage(
            context: context,
            applicationName: l.app_name,
            applicationVersion: version,
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l.settings_licenses,
                  style: context.bodyText.bodyMedium!.copyWith(
                    color: p.brassText,
                  ),
                ),
                AppIcon(
                  IconAsset.chevronRight,
                  size: Metrics.iconSmall,
                  color: p.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroProfile extends ConsumerWidget {
  const _HeroProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;
    final name = ref.watch(settingsProvider).value?.displayName;
    final xp = ref.watch(totalXpProvider).value ?? 0;
    final initial = name?.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(Space.s12),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.boardLine),
        borderRadius: BorderRadius.circular(Radii.group),
      ),
      child: Row(
        children: [
          Container(
            height: Metrics.buttonHeight,
            width: Metrics.buttonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.brassSoft,
              shape: BoxShape.circle,
            ),
            child: initial == null
                ? AppIcon(IconAsset.quests, color: palette.brassText)
                : Text(
                    initial,
                    style: context.displayText.headlineMedium?.copyWith(
                      color: palette.brassText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? strings.settings_heroNamePlaceholder,
                  style: context.bodyText.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: const FontWeight(750),
                  ),
                ),
                Text(
                  strings.settings_totalXp(xp),
                  style: context.bodyText.bodySmall?.copyWith(
                    fontSize: 13.5,
                    color: palette.textDim,
                  ),
                ),
              ],
            ),
          ),
          HeaderAction(
            icon: IconAsset.edit,
            semanticLabel: strings.settings_editHeroName,
            onPressed: () => showHeroNameSheet(context, initial: name ?? ''),
          ),
        ],
      ),
    );
  }
}
