import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll;
import 'package:daylog/quests/domain/xp_rules.dart';
import 'package:daylog/quests/data/models.dart';
import 'package:daylog/quests/ui/state/reward_queue.dart';

Mission _mission() => Mission(
  id: 2,
  name: 'Mission',
  bonus: MissionBonus.medium,
  status: MissionStatus.open,
  ruleId: null,
  createdAt: DateTime(2026, 11, 1),
  completedAt: null,
  awardedBonus: null,
);

void main() {
  group('Property 4: reward events reflect the service result', () {
    Glados3(any.intInRange(1, 50), any.intInRange(0, 3), any.intInRange(0, 300))
        .test('rewardForMission', (levelBefore, rise, bonus) {
          final event = rewardForMission(
            _mission(),
            CompleteMissionResult(
              awardedBonus: bonus,
              levelBefore: levelBefore,
              levelAfter: levelBefore + rise,
            ),
          );
          expect(event.levelUp, rise > 0);
          expect(event.bonus, bonus);
          expect(event.level, levelBefore + rise);
          expect(event.missionName, 'Mission');
        });
  });

  group('RewardQueue', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer();
      container.listen(rewardQueueProvider, (_, _) {});
    });
    tearDown(() => container.dispose());

    RewardEvent? current() => container.read(currentRewardProvider);

    test('is empty at start and dismissing an empty queue is a no-op', () {
      expect(current(), isNull);
      container.read(rewardQueueProvider.notifier).dismissCurrent();
      expect(container.read(rewardQueueProvider), isEmpty);
    });

    test('events pushed in quick succession show one at a time, in order', () {
      final queue = container.read(rewardQueueProvider.notifier);
      final a = rewardForMission(
        _mission(),
        const CompleteMissionResult(
          awardedBonus: 100,
          levelBefore: 1,
          levelAfter: 1,
        ),
      );
      final b = rewardForMission(
        _mission(),
        const CompleteMissionResult(
          awardedBonus: 25,
          levelBefore: 1,
          levelAfter: 2,
        ),
      );
      final c = rewardForMission(
        _mission(),
        const CompleteMissionResult(
          awardedBonus: 25,
          levelBefore: 2,
          levelAfter: 2,
        ),
      );
      queue
        ..push(a)
        ..push(b)
        ..push(c);

      expect(current(), same(a));
      queue.dismissCurrent();
      expect(current(), same(b));
      queue.dismissCurrent();
      expect(current(), same(c));
      queue.dismissCurrent();
      expect(current(), isNull);
    });
  });
}
