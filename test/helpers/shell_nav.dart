import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/shell/app_drawer.dart';
import 'package:daylog/shell/destination.dart';
import 'package:daylog/shell/module_bar.dart';
import 'package:daylog/shell/module_launcher.dart';
import 'package:daylog/ui_kit/common/menu_button.dart';

/// Opens the destination through the module bar or the drawer.
Future<void> tapDestination(
  WidgetTester tester,
  Destination destination, {
  bool viaDrawer = false,
}) async {
  if (viaDrawer) {
    await tester.tap(find.byType(MenuButton).hitTestable().first);
    await tester.pumpAndSettle();
    final row = find.byKey(drawerItemKey(destination));
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    return;
  }
  final tab = find.byKey(moduleBarTabKey(destination));
  if (tab.evaluate().isEmpty) {
    await tester.tap(find.byKey(moduleButtonKey));
    await tester.pumpAndSettle();
    final tile = find.byKey(launcherTileKey(destination.module));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
  await tester.tap(tab);
  await tester.pumpAndSettle();
}
