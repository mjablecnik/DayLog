import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/shell/app_drawer.dart';
import 'package:zafling/shell/destination.dart';
import 'package:zafling/ui_kit/common/menu_button.dart';

/// Shows [destination]: a tab by a tap on the Bottom_Bar, any other page
/// through the menu button and the Drawer, or every page through the Drawer
/// when [viaDrawer] is set. The caller settles the page.
Future<void> tapDestination(
  WidgetTester tester,
  Destination destination, {
  bool viaDrawer = false,
}) async {
  if (destination.isTab && !viaDrawer) {
    await tester.tap(find.byKey(ValueKey<Destination>(destination)));
    return;
  }
  await tester.tap(find.byType(MenuButton).hitTestable().first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(drawerItemKey(destination)));
  await tester.pumpAndSettle();
}
