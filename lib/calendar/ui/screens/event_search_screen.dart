import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/calendar_providers.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../widgets/calendar_fields.dart';
import '../../../ui_kit/layout/header_action.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/common/empty_state.dart';
import 'calendar_labels.dart';
import 'event_detail_screen.dart';

/// Opens the event search.
Future<void> showEventSearch(BuildContext context) =>
    Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => const EventSearchScreen()));

/// Finds events by name, details or location, ignoring case and diacritics.
/// The Type_Filter does not apply here.
class EventSearchScreen extends ConsumerStatefulWidget {
  const EventSearchScreen({super.key});

  @override
  ConsumerState<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends ConsumerState<EventSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _results = const <SearchResult>[];
  String _query = '';
  int _token = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String text) async {
    final int token = ++_token;
    setState(() => _query = text);
    final List<SearchResult> found = await ref.read(calendarServiceProvider).search(text);
    if (!mounted || token != _token) return;
    setState(() => _results = found);
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;
    final bool empty = _query.trim().isEmpty;
    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.s12,
                Space.s8,
                Space.s16,
                Space.s8,
              ),
              child: Row(
                children: <Widget>[
                  HeaderBareAction(
                    key: const ValueKey<String>('search-back'),
                    icon: IconAsset.arrowLeft,
                    semanticLabel: l.common_back,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: Space.s4),
                  Expanded(
                    child: CalendarTextField(
                      key: const ValueKey<String>('search-field'),
                      controller: _controller,
                      hint: l.calendar_search,
                      autofocus: true,
                      onChanged: _search,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: empty
                  ? Padding(
                      padding: const EdgeInsets.all(Space.s20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l.calendar_searchPrompt,
                          style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                        ),
                      ),
                    )
                  : _results.isEmpty
                  ? Semantics(
                      liveRegion: true,
                      child: EmptyState(
                        title: l.calendar_searchNone,
                        icon: IconAsset.search,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        Space.s16, Space.s12, Space.s16, Space.s24,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        final event = result.event;
                        final date = shortDateLabel(result.occurrenceDate, locale);
                        final type = eventTypeName(l, event.type);
                        final edges = (
                          first: index == 0,
                          last: index == _results.length - 1,
                        );
                        void open() =>
                            showEventDetail(context, event.id, result.occurrenceDate);
                        return Material(
                          color: p.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: groupedRadius(edges),
                            side: BorderSide.none,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: groupedBorder(p.boardLine, edges),
                              borderRadius: groupedRadius(edges),
                            ),
                            child: Semantics(
                              button: true,
                              label: '${event.name}, $type, $date',
                              excludeSemantics: true,
                              onTap: open,
                              child: ListRow(
                                key: ValueKey<String>('search-result-${event.id}'),
                                title: event.name,
                                subtitle: '$type · $date',
                                leading: SizedBox.square(
                                  dimension: Space.s12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: p.eventColor(event.type),
                                    ),
                                  ),
                                ),
                                onTap: open,
                              ),
                            ),
                          ),
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
