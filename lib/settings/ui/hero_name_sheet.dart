import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/validation.dart';
import '../../l10n/app_localizations.dart';
import '../../quests/services/providers.dart';
import '../../ui_kit/common/snackbar_host.dart';
import '../../ui_kit/forms/error_text.dart';
import '../../ui_kit/forms/validators.dart';
import '../../ui_kit/sheet/app_sheet.dart';

Future<void> showHeroNameSheet(
  BuildContext context, {
  required String initial,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => HeroNameSheet(initial: initial),
  );
}

class HeroNameSheet extends ConsumerStatefulWidget {
  const HeroNameSheet({super.key, required this.initial});

  final String initial;

  @override
  ConsumerState<HeroNameSheet> createState() => _HeroNameSheetState();
}

class _HeroNameSheetState extends ConsumerState<HeroNameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (validateHeroName(name) != null) return;
    try {
      await ref.read(settingsServiceProvider).setHeroName(name);
      if (mounted) AppSheet.close(context);
    } on DomainError catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        domainErrorText(AppLocalizations.of(context), error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final value = _controller.text;
    final error = validateHeroName(value);
    return AppSheet(
      title: strings.settings_heroNameLabel,
      primaryLabel: strings.common_save,
      primaryEnabled: error == null,
      onPrimary: _save,
      isDirty: value != widget.initial,
      child: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: strings.settings_heroNameLabel,
          hintText: strings.settings_heroNamePlaceholder,
          errorText: error == null ? null : fieldErrorText(strings, error),
          counterText: strings.settings_heroNameCounter(
            value.trim().runes.length,
            maxHeroNameLength,
          ),
        ),
      ),
    );
  }
}
