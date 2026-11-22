import 'package:daylog/core/ui_preferences.dart';
import 'package:daylog/shell/destination.dart';
import 'package:daylog/shell/module.dart';
import 'package:daylog/shell/module_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ui_kit/common/_harness.dart';

void main() {
  testWidgets('shows the active module pages and moves the module button', (
    tester,
  ) async {
    for (final side in ModuleButtonSide.values) {
      Destination? selected;
      await pumpCommon(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: ModuleBar(
            location: ShellLocation.at(Destination.history),
            side: side,
            hasPrevious: false,
            onSelectPage: (page) => selected = page,
            onOpenLauncher: () {},
            onPreviousModule: () {},
          ),
        ),
      );
      final button = tester.getCenter(find.byKey(moduleButtonKey));
      final timer = find.byKey(moduleBarTabKey(Destination.timer));
      final timerCenter = tester.getCenter(timer);
      expect(button.dx < timerCenter.dx, side == ModuleButtonSide.left);
      expect(find.byKey(moduleBarTabKey(Destination.missions)), findsNothing);
      await tester.tap(timer);
      expect(selected, Destination.timer);
    }
  });

  testWidgets('switches to the previous module once per swipe', (tester) async {
    var swipes = 0;
    var taps = 0;
    await pumpCommon(
      tester,
      Center(
        child: ModuleButton(
          module: Module.time,
          onTap: () => taps++,
          onSwipe: () => swipes++,
          hasPrevious: true,
        ),
      ),
    );

    final button = find.byType(ModuleButton);
    await tester.drag(button, const Offset(96, 0));
    expect(swipes, 1);
    expect(taps, 0);
    await tester.tap(button);
    expect(taps, 1);
  });
}
