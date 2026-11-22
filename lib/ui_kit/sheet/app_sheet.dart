import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';
import '../controls/app_buttons.dart';
import '../layout/header_action.dart';
import 'confirm_destructive.dart';

/// Opens a bottom sheet and resolves to the value the sheet closed with (or
/// `null` when it was dismissed).
///
/// ## How the sheet pieces fit together
///
/// [showAppSheet] only provides the route: modal scrim, the slide from
/// the bottom (a plain fade of at most [Motion.reducedFade] when the device
/// asks for reduced motion), keyboard-inset handling and the maximum height.
/// What the user sees is a [AppSheet], which [builder] returns. Form
/// sheets are therefore small widgets that own their form state and build the
/// scaffold themselves, so they can feed it the current dirtiness and
/// validity:
///
/// ```dart
/// final Quest? saved = await showAppSheet<Quest>(
///   context,
///   builder: (BuildContext context) => const QuestSheet(),
/// );
///
/// class _QuestSheetState extends ConsumerState<QuestSheet> {
///   @override
///   Widget build(BuildContext context) {
///     final AppLocalizations l10n = AppLocalizations.of(context);
///     return AppSheet(
///       title: l10n.quest_createTitle,
///       primaryLabel: l10n.quest_createAction,
///       isDirty: _nameController.text.isNotEmpty,
///       onPrimary: () async {
///         if (!_validate()) return; // stays open, input is kept
///         final Quest quest = await ref.read(questServiceProvider).create(...);
///         if (context.mounted) AppSheet.close(context, quest);
///       },
///       child: Column(children: <Widget>[/* fields */]),
///     );
///   }
/// }
/// ```
///
/// Dismissal rules (requirements 5.8, 9.8, 18.5): when [AppSheet.isDirty]
/// is true, every dismissal path (Cancel, drag down, tapping the scrim, the
/// system back gesture) asks the "discard changes?" question first; a clean
/// sheet closes straight away. [AppSheet.close] (used after a successful
/// save) never asks.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  return navigator.push<T>(
    _SheetRoute<T>(
      builder: builder,
      barrierColor: context.palette.scrim,
      barrierLabel: AppLocalizations.of(context).common_close,
      reducedMotion: MediaQuery.disableAnimationsOf(context),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
    ),
  );
}

/// The visual sheet: grabber, title and close action, a scrollable body and
/// one brass primary button pinned at
/// the bottom. While the keyboard is open the button (and the footer) scroll
/// with the body instead, so they do not take room above the keyboard.
///
/// Put it at the root of the widget returned from the [showAppSheet]
/// builder. It is rebuilt by its owner, so the owner must call `setState`
/// whenever [isDirty], [primaryEnabled] or [onPrimary] change meaning (form
/// sheets do that anyway to show validation).
class AppSheet extends StatefulWidget {
  const AppSheet({
    super.key,
    required this.title,
    this.primaryLabel,
    required this.child,
    this.primaryIcon,
    this.onPrimary,
    this.primaryEnabled = true,
    this.isDirty = false,
    this.headerAction,
    this.dismissible = true,
    this.footer,
    this.subtitle,
    this.discardCopy,
  });

  /// Already localized title.
  final String title;
  final HeaderAction? headerAction;
  final bool dismissible;
  final Widget? footer;
  final String? subtitle;
  final ({String title, String body, String confirm, String cancel})?
  discardCopy;

  /// Already localized label of the brass button ("Vyvěsit quest", "Uložit").
  /// Null for a sheet that has no primary button (a sheet of choices).
  final String? primaryLabel;

  /// Optional [IconAsset] shown before the label of the brass button (the
  /// artboards give the create sheets one).
  final String? primaryIcon;

  /// Scrollable body. Keep it free of its own vertical scrollables.
  final Widget child;

  /// Runs when the primary button is pressed. While the returned future runs
  /// the button is disabled, so a slow save cannot be submitted twice. The
  /// callback decides whether the sheet closes by calling
  /// [AppSheet.close] on success; on a validation or service error it
  /// simply returns and the sheet stays open with the input intact.
  final Future<void> Function()? onPrimary;

  /// Greys out the primary button when false (or when [onPrimary] is null).
  final bool primaryEnabled;

  /// True when the sheet holds input that would be lost; every dismissal then
  /// asks for confirmation first.
  final bool isDirty;

  /// Closes the sheet that contains [context] with [result], without asking
  /// for confirmation. Call it after the save succeeded.
  static void close<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Dismisses the sheet as if the user had pressed "Zrušit": asks for
  /// confirmation when the sheet is dirty, closes straight away otherwise.
  static Future<bool> requestClose(BuildContext context) {
    return Navigator.of(context).maybePop();
  }

  @override
  State<AppSheet> createState() => _AppSheetState();
}

class _AppSheetState extends State<AppSheet> {
  /// Fraction of the sheet height after which a drag releases into dismissal.
  static const double _dismissFraction = 0.3;

  /// Fling speed in logical pixels per second that dismisses regardless of
  /// distance.
  static const double _dismissVelocity = 700;

  bool _busy = false;
  bool _confirming = false;

  /// Set while the close button or a drag down asks to close. Any other close
  /// request (the scrim, the back gesture) only hides an open keyboard first.
  bool _closeRequested = false;
  bool _dragging = false;
  double _dragOffset = 0;

  Future<void> _submit() async {
    final Future<void> Function()? action = widget.onPrimary;
    if (action == null || _busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDiscard() async {
    if (_confirming) return;
    _confirming = true;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final copy = widget.discardCopy;
    final bool discard = await confirmDestructive(
      context,
      title: copy?.title ?? l10n.sheet_discardTitle,
      body: copy?.body ?? l10n.sheet_discardBody,
      confirmLabel: copy?.confirm ?? l10n.common_discard,
      cancelLabel: copy?.cancel ?? l10n.sheet_keepEditing,
    );
    _confirming = false;
    if (discard && mounted) Navigator.of(context).pop();
  }

  Future<void> _requestClose() async {
    _closeRequested = true;
    try {
      await Navigator.of(context).maybePop();
    } finally {
      _closeRequested = false;
    }
  }

  void _dragStart(DragStartDetails details) {
    setState(() => _dragging = true);
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = math.max(0, _dragOffset + details.delta.dy);
    });
  }

  void _dragEnd(DragEndDetails details) {
    final double height = context.size?.height ?? 0;
    final bool release =
        _dragOffset > height * _dismissFraction ||
        (details.primaryVelocity ?? 0) > _dismissVelocity;
    setState(() {
      _dragging = false;
      // A dirty sheet stays put while the confirmation is shown.
      if (!release || widget.isDirty) _dragOffset = 0;
    });
    if (release) _requestClose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final bool reduced = media.disableAnimations;
    final bool canSubmit =
        widget.onPrimary != null && widget.primaryEnabled && !_busy;
    final bool keyboardOpen = _KeyboardOpen.of(context);
    final Widget? button = widget.primaryLabel == null
        ? null
        : AppButton.primary(
            label: widget.primaryLabel!,
            icon: widget.primaryIcon,
            onPressed: canSubmit ? _submit : null,
          );

    final Widget sheet = Material(
      color: palette.sheet,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Radii.sheetTop),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: widget.dismissible ? _dragStart : null,
            onVerticalDragUpdate: widget.dismissible ? _dragUpdate : null,
            onVerticalDragEnd: widget.dismissible ? _dragEnd : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _Grabber(),
                _Header(
                  title: widget.title,
                  closeLabel: l10n.common_close,
                  action: widget.headerAction,
                  onCancel: widget.dismissible ? _requestClose : null,
                  subtitle: widget.subtitle,
                ),
              ],
            ),
          ),
          Flexible(
            // A tap on the body outside a field or button hides the keyboard;
            // dragging only scrolls.
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                padding: const EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s8,
                  Space.s20,
                  Space.s16,
                ),
                // The body is always the first child of this column, so opening
                // the keyboard never rebuilds it: a different wrapper would
                // recreate the text field and drop its focus at once.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    widget.child,
                    if (keyboardOpen) ...<Widget>[
                      if (button != null) ...<Widget>[
                        const SizedBox(height: Space.s16),
                        button,
                      ],
                      ?widget.footer,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (!keyboardOpen) ...<Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                Space.s20,
                Space.s4,
                Space.s20,
                widget.footer == null
                    ? Space.s12 + media.padding.bottom
                    : Space.s4,
              ),
              child: button,
            ),
            if (widget.footer case final footer?)
              Padding(
                padding: EdgeInsets.only(bottom: media.padding.bottom),
                child: footer,
              ),
          ],
        ],
      ),
    );

    return PopScope<Object?>(
      // With the keyboard open a close request from the scrim or the back
      // gesture only hides the keyboard; the next one closes the sheet.
      canPop: widget.dismissible && !widget.isDirty && !keyboardOpen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !widget.dismissible) return;
        if (keyboardOpen && !_closeRequested) {
          FocusManager.instance.primaryFocus?.unfocus();
        } else if (widget.isDirty) {
          _confirmDiscard();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: _dragOffset),
          duration: _dragging || reduced ? Motion.none : Motion.panel,
          curve: Motion.curve,
          builder: (BuildContext context, double offset, Widget? child) =>
              Transform.translate(offset: Offset(0, offset), child: child),
          child: sheet,
        ),
      ),
    );
  }
}

/// Tells the sheet whether the keyboard is open. The route removes the view
/// insets for the sheet, so this is the only way the sheet can know.
class _KeyboardOpen extends InheritedWidget {
  const _KeyboardOpen({required this.open, required super.child});

  final bool open;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_KeyboardOpen>()?.open ??
      false;

  @override
  bool updateShouldNotify(_KeyboardOpen oldWidget) => open != oldWidget.open;
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    // A pure drag handle: dismissing through assistive technology is covered
    // by the "Zrušit" button, so the grabber stays out of the semantics tree.
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s12),
        child: Center(
          child: Container(
            width: Metrics.grabberWidth,
            height: Metrics.grabberHeight,
            decoration: BoxDecoration(
              color: context.palette.textFaint,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.closeLabel,
    required this.onCancel,
    this.action,
    this.subtitle,
  });

  final String title;
  final String closeLabel;
  final VoidCallback? onCancel;
  final String? subtitle;
  final HeaderAction? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.s20),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                container: true,
                header: true,
                namesRoute: true,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineMedium,
                ),
              ),
              if (subtitle case final text?)
                Text(
                  text,
                  style: context.bodyText.bodySmall?.copyWith(
                    color: context.palette.textDim,
                  ),
                ),
            ],
          ),
        ),
        if (action case final button?) ...[
          const SizedBox(width: Space.s6),
          button,
        ],
        if (onCancel != null) ...[
          const SizedBox(width: Space.s6),
          HeaderAction(
            icon: IconAsset.close,
            semanticLabel: closeLabel,
            onPressed: onCancel,
          ),
        ],
      ],
    ),
  );
}

class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({
    required this.builder,
    required this.barrierColor,
    required this.barrierLabel,
    required this.reducedMotion,
    required this.capturedThemes,
  });

  final WidgetBuilder builder;
  final bool reducedMotion;
  final CapturedThemes capturedThemes;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration =>
      reducedMotion ? Motion.reducedFade : Motion.panel;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final MediaQueryData media = MediaQuery.of(context);
    return capturedThemes.wrap(
      Padding(
        padding: EdgeInsets.only(
          top: media.padding.top + Space.s24,
          bottom: media.viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: _KeyboardOpen(
              open: media.viewInsets.bottom > 0,
              child: Builder(builder: builder),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reducedMotion) {
      return FadeTransition(opacity: animation, child: child);
    }
    return SlideTransition(
      position: animation
          .drive(CurveTween(curve: Motion.curve))
          .drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)),
      child: child,
    );
  }
}
