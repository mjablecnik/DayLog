import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _fontWeights = <String, List<int>>{
  'Figtree': [400, 500, 600, 700, 800],
};

const _icons = <String>[
  'alert',
  'arrow_left',
  'bell',
  'contrast',
  'download',
  'flag',
  'flask',
  'globe',
  'minus',
  'monitor',
  'pause',
  'play',
  'refresh',
  'smartphone',
  'stop',
  'upload',
  'arrow_up',
  'auto',
  'bold',
  'calendar',
  'check',
  'checklist',
  'chevron_left',
  'chevron_right',
  'close',
  'code',
  'drag',
  'edit',
  'filter',
  'folder',
  'folder_plus',
  'location',
  'menu',
  'gear',
  'heading',
  'history',
  'italic',
  'link',
  'list',
  'missions',
  'moon',
  'more',
  'move',
  'note',
  'note_plus',
  'notes',
  'plus',
  'quests',
  'quote',
  'rays',
  'repeat',
  'search',
  'seal_check',
  'statistics',
  'sun',
  'timer',
  'tick',
  'trash',
  'undo',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the one font family, Figtree, is declared with all its weights',
      () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json'))
            as List<dynamic>;
    final declared = {
      for (final entry in manifest)
        (entry as Map<String, dynamic>)['family'] as String: [
          for (final font in entry['fonts'] as List<dynamic>)
            (font as Map<String, dynamic>)['weight'] as int? ?? 400,
        ],
    };
    for (final MapEntry(key: family, value: weights) in _fontWeights.entries) {
      expect(declared.keys, contains(family), reason: 'family $family');
      expect(declared[family]!..sort(), weights, reason: 'weights of $family');
    }
  });

  test('every font file declared in the manifest loads', () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json'))
            as List<dynamic>;
    for (final entry in manifest) {
      for (final font in (entry as Map<String, dynamic>)['fonts'] as List) {
        final asset = (font as Map<String, dynamic>)['asset'] as String;
        if (!asset.startsWith('assets/fonts/')) continue;
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(10000), reason: asset);
      }
    }
  });

  test('every icon asset is declared and is a non-empty SVG', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final name in _icons) {
      final path = 'assets/icons/$name.svg';
      expect(manifest.listAssets(), contains(path), reason: path);
      final svg = await rootBundle.loadString(path);
      expect(svg, contains('<svg'), reason: path);
      expect(svg, contains('currentColor'), reason: path);
    }
  });

  test('no declared icon is missing from the expected list', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final declared = manifest
        .listAssets()
        .where((a) => a.startsWith('assets/icons/'))
        .map((a) => a.substring('assets/icons/'.length, a.length - 4))
        .toSet();
    expect(declared, _icons.toSet());
  });

  test('no code draws an icon from an icon font', () {
    final RegExp fontIcon = RegExp(r'\b(Icons|CupertinoIcons)\.|[^A-Za-z]Icon\(|IconData\(');
    final List<String> offences = <String>[];
    for (final File file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      // The time tracking feature keeps TimeLog's Material icons for now (listed in
      // .agents/REFACTOR.md); every other code draws the bundled SVG icons.
      if (!file.path.endsWith('.dart') || file.path.startsWith('lib/time_tracking/')) continue;
      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        if (fontIcon.hasMatch(lines[i].replaceFirst(RegExp(r'//.*$'), ''))) {
          offences.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offences, isEmpty);
  });
}
