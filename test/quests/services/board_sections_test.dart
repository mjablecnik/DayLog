import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/core/errors.dart';
import 'package:daylog/quests/domain/xp_rules.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/quests/data/models.dart';
import 'package:daylog/quests/services/mission_service.dart';
import 'package:daylog/quests/services/quest_service.dart';
import 'package:daylog/quests/services/xp_engine.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late QuestService quests;
  late MissionService missions;

  setUp(() {
    db = createTestDatabase();
    final xp = XpEngine(db);
    final clock = FixedClock(DateTime(2026, 11, 15, 10));
    quests = QuestService(db, xp, clock);
    missions = MissionService(db, xp, clock);
  });
  tearDown(() => db.close());

  List<String> names(List<Quest> quests) => [for (final q in quests) q.name];

  QuestDraft draft(String name, {int? missionId, BoardSection? board}) => QuestDraft(
    name: name,
    difficulty: Difficulty.easy,
    missionId: missionId,
    board: board,
  );

  group('board section of a new Quest', () {
    test('a Quest without a Mission lands in Todo', () async {
      final created = await quests.create(draft('loose'));
      expect(created.board, BoardSection.todo);
    });

    test('a Quest of a Mission starts off the Board', () async {
      final mission = await seedMission(db);
      final created = await quests.create(draft('inside', missionId: mission));
      expect(created.board, isNull);
      expect(await quests.watchOpenBoard().first, isEmpty);
    });

    test('a Quest of a Mission can be posted to Today right away', () async {
      final mission = await seedMission(db);
      await quests.create(draft('focus', missionId: mission, board: BoardSection.today));
      final board = await quests.watchOpenBoard().first;
      expect(names(board), ['focus']);
      expect(board.single.board, BoardSection.today);
    });
  });

  group('update', () {
    test('joining a Mission without a section takes the Quest off the Board', () async {
      final mission = await seedMission(db);
      final created = await quests.create(draft('x'));
      final moved = await quests.update(created.id, draft('x', missionId: mission));
      expect(moved.board, isNull);
    });

    test('a Mission Quest keeps the section it is given, and may leave the Board', () async {
      final mission = await seedMission(db);
      final created = await quests.create(draft('x', missionId: mission));
      final onBoard = await quests.update(
        created.id,
        draft('x', missionId: mission, board: BoardSection.todo),
      );
      expect(onBoard.board, BoardSection.todo);
      final off = await quests.update(created.id, draft('x', missionId: mission));
      expect(off.board, isNull);
    });

    test('leaving a Mission puts the Quest in Todo', () async {
      final mission = await seedMission(db);
      final created = await quests.create(draft('x', missionId: mission));
      final loose = await quests.update(created.id, draft('x'));
      expect(loose.board, BoardSection.todo);
    });
  });

  group('moveOnBoard', () {
    test('moves a Quest into the other section at the requested place', () async {
      final a = await quests.create(draft('a'));
      final b = await quests.create(draft('b'));
      final c = await quests.create(draft('c'));
      await quests.moveOnBoard(c.id, BoardSection.today, [c.id]);
      await quests.moveOnBoard(a.id, BoardSection.today, [a.id, c.id]);

      final board = await quests.watchOpenBoard().first;
      expect(names(board.where((q) => q.board == BoardSection.today).toList()), ['a', 'c']);
      expect(names(board.where((q) => q.board == BoardSection.todo).toList()), ['b']);
      expect(b.board, BoardSection.todo);
    });

    test('rejects a done Quest and an order that omits the Quest', () async {
      final a = await quests.create(draft('a'));
      final b = await quests.create(draft('b'));
      await expectLater(
        quests.moveOnBoard(a.id, BoardSection.today, [b.id]),
        throwsA(isA<ValidationError>()),
      );
      await quests.complete(a.id);
      await expectLater(
        quests.moveOnBoard(a.id, BoardSection.today, [a.id]),
        throwsA(isA<InvalidStateError>()),
      );
    });
  });

  group('done Quests on the Board', () {
    test('a Mission Quest done while on the Board shows in done today; one off the Board does not', () async {
      final mission = await seedMission(db);
      final on = await quests.create(draft('on', missionId: mission, board: BoardSection.today));
      final off = await quests.create(draft('off', missionId: mission));
      await quests.complete(on.id);
      await quests.complete(off.id);

      final done = await quests.watchDoneToday(DateTime(2026, 11, 15)).first;
      expect(names(done), ['on']);
    });
  });

  group('Mission order', () {
    test('new Missions go last and reorder changes the open list', () async {
      final a = await missions.create(const MissionDraft(name: 'a', bonus: MissionBonus.small));
      final b = await missions.create(const MissionDraft(name: 'b', bonus: MissionBonus.small));
      final c = await missions.create(const MissionDraft(name: 'c', bonus: MissionBonus.small));
      List<String> order(List<MissionSummary> l) => [for (final m in l) m.name];

      expect(order(await missions.watchOpen().first), ['a', 'b', 'c']);
      await missions.reorder([c.id, a.id]);
      expect(order(await missions.watchOpen().first), ['c', 'b', 'a']);
      await missions.reorder([b.id, c.id]);
      expect(order(await missions.watchOpen().first), ['b', 'c', 'a']);
    });

    test('reorder rejects duplicate and unknown ids', () async {
      final a = await missions.create(const MissionDraft(name: 'a', bonus: MissionBonus.small));
      await expectLater(missions.reorder([a.id, a.id]), throwsA(isA<ValidationError>()));
      await expectLater(missions.reorder([a.id, 999]), throwsA(isA<ValidationError>()));
    });
  });
}
