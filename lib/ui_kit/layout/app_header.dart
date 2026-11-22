import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';
import '../common/menu_button.dart';
import 'header_action.dart';

enum HeaderLeading { menu, back, close, none }

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.titleSuffix,
    this.subtitle,
    this.subtitleWidget,
    this.onTitleTap,
    this.titleActionLabel,
    this.leading = HeaderLeading.menu,
    this.onLeading,
    this.leadingKey,
    this.trailing = const <Widget>[],
  }) : assert(trailing.length <= 2);

  final String title;
  final String? titleSuffix;
  final String? subtitle;
  final Widget? subtitleWidget;
  final VoidCallback? onTitleTap;
  final String? titleActionLabel;
  final HeaderLeading leading;
  final VoidCallback? onLeading;
  final Key? leadingKey;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final pop = onLeading ?? () => Navigator.maybePop(context);
    final leadingWidget = switch (leading) {
      HeaderLeading.menu when onLeading != null => HeaderAction(
        icon: IconAsset.menu,
        semanticLabel: strings.shell_openMenu,
        onPressed: onLeading,
      ),
      HeaderLeading.menu => const MenuButton(),
      HeaderLeading.back => HeaderBareAction(
        key: leadingKey,
        icon: IconAsset.arrowLeft,
        semanticLabel: strings.common_back,
        onPressed: pop,
      ),
      HeaderLeading.close => HeaderBareAction(
        key: leadingKey,
        icon: IconAsset.close,
        semanticLabel: strings.common_close,
        onPressed: pop,
      ),
      HeaderLeading.none => null,
    };

    final titleStyle = context.displayText.headlineLarge;
    final suffix = titleSuffix;
    final titleText = Semantics(
      header: true,
      child: suffix == null
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            )
          : Text.rich(
              TextSpan(
                text: title,
                children: [
                  TextSpan(
                    text: ' $suffix',
                    style: TextStyle(
                      color: context.palette.textDim,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
    );
    final heading = onTitleTap == null
        ? titleText
        : Semantics(
            button: true,
            label: titleActionLabel,
            excludeSemantics: titleActionLabel != null,
            onTap: onTitleTap,
            child: InkWell(
              onTap: onTitleTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: titleText,
                ),
              ),
            ),
          );

    final scale = MediaQuery.textScalerOf(context);
    final titleSize = context.displayText.headlineLarge?.fontSize ?? 22;
    final subtitleSize = context.bodyText.bodySmall?.fontSize ?? 12.5;
    final subtitleHeight = subtitle != null || subtitleWidget != null
        ? scale.scale(subtitleSize) * 1.35
        : 0.0;
    final height = math.max(
      Metrics.header,
      scale.scale(titleSize) * 1.1 + subtitleHeight + Space.s8,
    );
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s12),
        child: Row(
          children: [
            ?leadingWidget,
            const SizedBox(width: Space.s8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading,
                  if (subtitleWidget case final widget?)
                    widget
                  else if (subtitle case final text?)
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.bodySmall?.copyWith(
                        color: context.palette.textDim,
                      ),
                    ),
                ],
              ),
            ),
            for (final action in trailing) ...[
              const SizedBox(width: Space.s6),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
