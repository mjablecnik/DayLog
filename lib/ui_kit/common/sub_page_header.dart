import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// The header of a page opened from another page: a back button where a top
/// level page has the menu button, at the same place, and the title beside it.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final String back = MaterialLocalizations.of(context).backButtonTooltip;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
        child: Row(
          children: <Widget>[
            Semantics(
              button: true,
              label: back,
              excludeSemantics: true,
              onTap: () => Navigator.of(context).maybePop(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: Metrics.touchTarget,
                  height: Metrics.touchTarget,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppIcon(
                      IconAsset.chevronLeft,
                      size: Metrics.iconSize,
                      color: context.palette.textDim,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
