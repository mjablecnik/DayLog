import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Runs `scripts/release.sh` in a throw-away git repository.
void main() {
  late Directory repo;
  final String original = File('scripts/release.sh').readAsStringSync();

  ProcessResult git(List<String> args) => Process.runSync('git', args, workingDirectory: repo.path);

  // The script works on the project it lives in, so it runs from a copy inside
  // the throw-away repository.
  ProcessResult release(String version) =>
      Process.runSync('bash', <String>['scripts/release.sh', version], workingDirectory: repo.path);

  void commit(String message) {
    File('${repo.path}/file.txt').writeAsStringSync('$message ${DateTime.now().microsecondsSinceEpoch}');
    git(<String>['add', '-A']);
    expect(git(<String>['commit', '-q', '-m', message]).exitCode, 0);
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('release_test_');
    git(<String>['init', '-q']);
    git(<String>['config', 'user.name', 'Test']);
    git(<String>['config', 'user.email', 'test@example.com']);
    File('${repo.path}/pubspec.yaml').writeAsStringSync('name: demo\nversion: 0.0.1+7\n');
    File('${repo.path}/CHANGELOG.md').writeAsStringSync('# Changelog\n\n## [Unreleased]\n');
    Directory('${repo.path}/scripts').createSync();
    File('${repo.path}/scripts/release.sh').writeAsStringSync(original);
    commit('chore: start');
  });
  tearDown(() => repo.deleteSync(recursive: true));

  test('writes the grouped commits, bumps the version, commits and tags', () {
    commit('feat(shell): add a drawer');
    commit('fix: close the drawer on selection');
    commit('docs: explain the drawer');
    final ProcessResult result = release('1.0.0-dev.0');
    expect(result.exitCode, 0, reason: '${result.stderr}');

    final String changelog = File('${repo.path}/CHANGELOG.md').readAsStringSync();
    expect(changelog, contains('## [Unreleased]\n\n## [1.0.0-dev.0] - '));
    expect(changelog, contains('### Features\n\n- add a drawer (shell)'));
    expect(changelog, contains('### Fixes\n\n- close the drawer on selection'));
    expect(changelog, contains('### Other\n\n- docs: explain the drawer'));
    expect(changelog.indexOf('Unreleased'), lessThan(changelog.indexOf('1.0.0-dev.0')));

    expect(File('${repo.path}/pubspec.yaml').readAsStringSync(), contains('version: 1.0.0-dev.0+7'));
    expect(git(<String>['log', '-1', '--format=%s']).stdout.toString().trim(), 'chore: bump version to 1.0.0-dev.0');
    expect(git(<String>['tag', '-l', 'v1.0.0-dev.0']).stdout.toString().trim(), 'v1.0.0-dev.0');
    expect(git(<String>['cat-file', '-t', 'v1.0.0-dev.0']).stdout.toString().trim(), 'tag');
    expect(git(<String>['status', '--porcelain']).stdout.toString().trim(), isEmpty);
    expect(git(<String>['log', '-1', '--format=%B']).stdout.toString(), isNot(contains('Co-Authored-By')));
  });

  test('the next release lists only what came after the previous tag, without the bump commit', () {
    commit('feat: first');
    expect(release('1.0.0').exitCode, 0);
    commit('fix: second');
    expect(release('1.0.1').exitCode, 0);
    final String changelog = File('${repo.path}/CHANGELOG.md').readAsStringSync();
    final String newest = changelog.substring(changelog.indexOf('## [1.0.1]'), changelog.indexOf('## [1.0.0]'));
    expect(newest, contains('- second'));
    expect(newest, isNot(contains('first')));
    expect(newest, isNot(contains('bump version')));
    expect(changelog.indexOf('## [1.0.1]'), lessThan(changelog.indexOf('## [1.0.0]')));
  });

  test('refuses a dirty working tree and changes nothing', () {
    File('${repo.path}/pubspec.yaml').writeAsStringSync('name: demo\nversion: 0.0.1+7\n# edited\n');
    final ProcessResult result = release('1.0.0');
    expect(result.exitCode, isNot(0));
    expect(result.stderr.toString(), contains('not clean'));
    expect(git(<String>['tag']).stdout.toString().trim(), isEmpty);
  });

  test('refuses a version that is not semantic', () {
    for (final String bad in <String>['', '1', '1.0', 'v1.0.0', '1.0.0.0', '01.0.0']) {
      final ProcessResult result = release(bad);
      expect(result.exitCode, isNot(0), reason: bad);
      expect(result.stderr.toString(), contains('not a semantic version'), reason: bad);
    }
    expect(git(<String>['tag']).stdout.toString().trim(), isEmpty);
    expect(File('${repo.path}/pubspec.yaml').readAsStringSync(), contains('0.0.1+7'));
  });

  test('refuses a version that is already tagged', () {
    expect(release('1.0.0').exitCode, 0);
    commit('fix: later');
    final ProcessResult again = release('1.0.0');
    expect(again.exitCode, isNot(0));
    expect(again.stderr.toString(), contains('already exists'));
  });
}
