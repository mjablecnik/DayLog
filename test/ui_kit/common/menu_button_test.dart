import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/theme/tokens.dart';
import 'package:zafling/ui_kit/common/menu_button.dart';

import '_harness.dart';

void main() {
  testWidgets('MenuButton draws nothing without a ShellMenuScope', (tester) async {
    await pumpCommon(tester, const Row(children: <Widget>[MenuButton()]));
    expect(tester.getSize(find.byType(MenuButton)), Size.zero);
  });

  testWidgets('MenuButton has a 44 px target, a label and calls the scope', (tester) async {
    int opened = 0;
    await pumpCommon(
      tester,
      ShellMenuScope(open: () => opened++, child: const Row(children: <Widget>[MenuButton()])),
    );
    final Size size = tester.getSize(find.byType(MenuButton));
    expect(size.width, greaterThanOrEqualTo(Metrics.touchTarget));
    expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
    final SemanticsHandle handle = tester.ensureSemantics();
    expect(tester.getSemantics(find.byType(MenuButton)).label, 'Menu');
    handle.dispose();
    await tester.tap(find.byType(MenuButton));
    expect(opened, 1);
  });
}
