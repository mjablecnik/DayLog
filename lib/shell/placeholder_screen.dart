import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/quest_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/menu_button.dart';
import 'destination.dart';

/// Stands in for a Destination whose feature is not moved into the app yet
/// (the timer pages, until the TimeLog port replaces them).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s20,
            vertical: Space.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const MenuButton(),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        destination.label(l),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.displayText.headlineLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.s24),
              Text(l.shell_placeholderBody, style: context.bodyText.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
