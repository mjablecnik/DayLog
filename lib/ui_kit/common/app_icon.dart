import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/tokens.dart';

/// Names of the bundled SVG icons in `assets/icons/`.
abstract final class IconAsset {
  static const monitor = 'monitor';
  static const flag = 'flag';
  static const stop = 'stop';
  static const pause = 'pause';
  static const play = 'play';
  static const minus = 'minus';
  static const bell = 'bell';
  static const download = 'download';
  static const upload = 'upload';
  static const flask = 'flask';
  static const smartphone = 'smartphone';
  static const contrast = 'contrast';
  static const globe = 'globe';
  static const refresh = 'refresh';
  static const alert = 'alert';
  static const arrowLeft = 'arrow_left';
  static const arrowUp = 'arrow_up';
  static const auto = 'auto';
  static const calendar = 'calendar';
  static const check = 'check';
  static const chevronLeft = 'chevron_left';
  static const chevronRight = 'chevron_right';
  static const close = 'close';
  static const drag = 'drag';
  static const filter = 'filter';
  static const location = 'location';
  static const note = 'note';
  static const search = 'search';
  static const edit = 'edit';
  static const gear = 'gear';
  static const missions = 'missions';
  static const moon = 'moon';
  static const more = 'more';
  static const plus = 'plus';
  static const quests = 'quests';
  static const rays = 'rays';
  static const repeat = 'repeat';
  static const sealCheck = 'seal_check';
  static const sun = 'sun';
  static const tick = 'tick';
  static const trash = 'trash';
  static const undo = 'undo';
  static const quote = 'quote';
  static const notes = 'notes';
  static const notePlus = 'note_plus';
  static const move = 'move';
  static const list = 'list';
  static const link = 'link';
  static const italic = 'italic';
  static const heading = 'heading';
  static const folderPlus = 'folder_plus';
  static const folder = 'folder';
  static const code = 'code';
  static const checklist = 'checklist';
  static const bold = 'bold';
  static const menu = 'menu';
  static const timer = 'timer';
  static const history = 'history';
  static const statistics = 'statistics';
}

/// A bundled SVG icon drawn with `currentColor` strokes, tinted by [color] or
/// the ambient [IconTheme] colour.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = Metrics.iconSize,
    this.color,
    this.semanticLabel,
  });

  /// One of the [IconAsset] names.
  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
