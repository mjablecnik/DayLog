import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/layout/app_header.dart';
import '../../ui_kit/layout/grouped_list.dart';

/// The open-source licences of the framework, packages and bundled fonts: the
/// packages as rows of a Grouped_List, each opening its licence texts.
class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key, this.version});

  final String? version;

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late final Future<Map<String, List<LicenseEntry>>> _licenses = _load();

  static Future<Map<String, List<LicenseEntry>>> _load() async {
    final Map<String, List<LicenseEntry>> byPackage =
        <String, List<LicenseEntry>>{};
    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      for (final String package in entry.packages) {
        byPackage.putIfAbsent(package, () => <LicenseEntry>[]).add(entry);
      }
    }
    return byPackage;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.palette.board,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppHeader(
              leading: HeaderLeading.back,
              title: l.settings_licenses,
              subtitle: widget.version == null
                  ? l.app_name
                  : '${l.app_name} ${l.settings_version(widget.version!)}',
            ),
            Expanded(
              child: FutureBuilder<Map<String, List<LicenseEntry>>>(
                future: _licenses,
                builder: (BuildContext context, AsyncSnapshot<Map<String, List<LicenseEntry>>> snapshot) {
                  final Map<String, List<LicenseEntry>>? data = snapshot.data;
                  if (data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<String> names = data.keys.toList()..sort();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Space.s20,
                      Space.s8,
                      Space.s20,
                      Space.s24,
                    ),
                    children: <Widget>[
                      GroupedList(
                        children: <Widget>[
                          for (final String name in names)
                            ListRow(
                              title: name,
                              value: '${data[name]!.length}',
                              showChevron: true,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => _LicenseTextScreen(
                                    package: name,
                                    entries: data[name]!,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseTextScreen extends StatelessWidget {
  const _LicenseTextScreen({required this.package, required this.entries});

  final String package;
  final List<LicenseEntry> entries;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppHeader(leading: HeaderLeading.back, title: package),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s8,
                  Space.s20,
                  Space.s24,
                ),
                children: <Widget>[
                  GroupedList(
                    children: <Widget>[
                      for (final LicenseEntry entry in entries)
                        Padding(
                          padding: const EdgeInsets.all(Space.s16),
                          child: Text(
                            <String>[
                              for (final LicenseParagraph paragraph
                                  in entry.paragraphs)
                                paragraph.text,
                            ].join('\n\n'),
                            style: context.bodyText.bodySmall!.copyWith(
                              color: p.textDim,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
