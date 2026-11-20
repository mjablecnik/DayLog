import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Folders under `lib/` that hold shared building blocks. They never import a
/// feature (the database is the one exception: it lists the table classes).
const Set<String> _shared = <String>{'core', 'theme', 'ui_kit', 'l10n'};

/// The QuestLog modules. They grew as one product and depend on each other
/// (the Board shows calendar events, an event awards XP, a Note in the Trash
/// reuses the quest actions); only a later spec may untangle them.
const Set<String> _planner = <String>{'quests', 'calendar', 'notes', 'settings'};

const String _timeTracking = 'time_tracking';

/// Folders that compose the app and may import every feature.
const Set<String> _composition = <String>{'shell'};

String _folder(String libPath) {
  final List<String> parts = p.split(libPath);
  return parts.length > 1 ? parts.first : '';
}

Iterable<(String, String)> _imports() sync* {
  final Directory lib = Directory('lib');
  final RegExp directive = RegExp(r'''^\s*(?:import|export)\s+'([^']+)';''', multiLine: true);
  for (final FileSystemEntity e in lib.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart') || e.path.endsWith('.g.dart')) continue;
    final String from = p.relative(e.path, from: 'lib');
    for (final RegExpMatch m in directive.allMatches(e.readAsStringSync())) {
      final String path = m.group(1)!;
      String? target;
      if (path.startsWith('package:zafling/')) {
        target = path.substring('package:zafling/'.length);
      } else if (!path.startsWith('package:') && !path.startsWith('dart:')) {
        target = p.normalize(p.join(p.dirname(from), path));
      }
      if (target != null) yield (from, target);
    }
  }
}

void main() {
  final List<(String, String)> imports = _imports().toList();

  test('lib/ has the expected top-level folders', () {
    final Set<String> found = <String>{
      for (final FileSystemEntity e in Directory('lib').listSync())
        if (e is Directory) p.basename(e.path),
    };
    expect(found.difference(<String>{..._shared, ..._planner, ..._composition, 'database', _timeTracking}), isEmpty);
  });

  test('shared folders import no feature', () {
    final List<String> bad = <String>[
      for (final (String from, String to) in imports)
        if (_shared.contains(_folder(from)) &&
            (_planner.contains(_folder(to)) || _folder(to) == _timeTracking || _composition.contains(_folder(to))))
          '$from -> $to',
    ];
    expect(bad, isEmpty);
  });

  test('the time tracking feature is isolated from the rest of the app', () {
    final List<String> bad = <String>[
      for (final (String from, String to) in imports)
        if (_folder(from) == _timeTracking &&
            _folder(to) != _timeTracking &&
            !_shared.contains(_folder(to)) &&
            _folder(to) != 'database')
          '$from -> $to',
    ];
    expect(bad, isEmpty);
  });

  test('the QuestLog modules do not import time tracking or the shell', () {
    final List<String> bad = <String>[
      for (final (String from, String to) in imports)
        if (_planner.contains(_folder(from)) &&
            (_folder(to) == _timeTracking || _composition.contains(_folder(to))))
          '$from -> $to',
    ];
    expect(bad, isEmpty);
  });
}
