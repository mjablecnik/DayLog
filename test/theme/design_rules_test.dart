import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new feature screens use the shared design system', () {
    final legacyWidgets = RegExp(
      r'\b(?:OutlinedButton|AlertDialog|ScreenHeader|SubPageHeader|SettingsNavRow)\s*\('
      r'|\bshowDialog(?:<[^>]+>)?\s*\('
      r'|\b(?:Icons\.|DashedBorderPainter\b)',
    );
    final offending = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') &&
              !file.path.startsWith('lib/ui_kit/') &&
              legacyWidgets.hasMatch(file.readAsStringSync()),
        )
        .map((file) => file.path)
        .toSet();
    expect(offending, isEmpty);
  });
}
