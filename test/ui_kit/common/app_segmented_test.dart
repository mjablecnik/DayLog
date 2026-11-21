import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/theme/tokens.dart';
import 'package:zafling/ui_kit/common/app_icon.dart';
import 'package:zafling/ui_kit/common/app_segmented.dart';

import '_harness.dart';

const List<SegmentedOption<String>> _options = <SegmentedOption<String>>[
  SegmentedOption<String>(value: 'cs', label: 'Čeština'),
  SegmentedOption<String>(value: 'en', label: 'English'),
];

void main() {
  testWidgets('tapping a segment reports its value', (tester) async {
    String? picked;
    await pumpCommon(
      tester,
      AppSegmented<String>(
        options: _options,
        selected: 'cs',
        onChanged: (String v) => picked = v,
      ),
    );
    await tester.tap(find.text('English'));
    expect(picked, 'en');
  });

  testWidgets('disabled control ignores taps', (tester) async {
    String? picked;
    await pumpCommon(
      tester,
      AppSegmented<String>(
        options: _options,
        selected: 'cs',
        enabled: false,
        onChanged: (String v) => picked = v,
      ),
    );
    await tester.tap(find.text('English'));
    expect(picked, isNull);
  });

  testWidgets('every segment is at least 44px tall and wide', (tester) async {
    await pumpCommon(
      tester,
      Center(
        child: SizedBox(
          width: 200,
          child: AppSegmented<String>(
            options: _options,
            selected: 'cs',
            onChanged: (_) {},
          ),
        ),
      ),
    );
    for (final String label in <String>['Čeština', 'English']) {
      final Size size = tester.getSize(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
      expect(size.width, greaterThanOrEqualTo(Metrics.touchTarget));
    }
  });

  testWidgets('exposes the selected state through semantics', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpCommon(
      tester,
      AppSegmented<String>(
        options: _options,
        selected: 'en',
        onChanged: (_) {},
      ),
    );
    final SemanticsNode en = tester.getSemantics(
      find.bySemanticsLabel('English'),
    );
    final SemanticsNode cs = tester.getSemantics(
      find.bySemanticsLabel('Čeština'),
    );
    expect(en.flagsCollection.isSelected, Tristate.isTrue);
    expect(cs.flagsCollection.isSelected, Tristate.isFalse);
    expect(en.flagsCollection.isButton, isTrue);
    expect(en.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    handle.dispose();
  });

  testWidgets('selected segment is highlighted and pressing shows state', (
    tester,
  ) async {
    await pumpCommon(
      tester,
      AppSegmented<String>(
        options: _options,
        selected: 'cs',
        onChanged: (_) {},
      ),
    );
    BoxDecoration decorationOf(String label) {
      final AnimatedContainer c = tester.widget(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return c.decoration! as BoxDecoration;
    }

    expect(decorationOf('Čeština').color, AppPalette.guildBoard.brassSoft);
    expect(decorationOf('English').color, isNull);

    final TestGesture g = await tester.startGesture(
      tester.getCenter(find.text('English')),
    );
    await tester.pump(Motion.hover);
    expect(decorationOf('English').color, AppPalette.guildBoard.brassSoft);
    await g.up();
    await tester.pump(Motion.hover);
  });

  testWidgets('renders optional icon and caption', (tester) async {
    await pumpCommon(
      tester,
      AppSegmented<int>(
        options: const <SegmentedOption<int>>[
          SegmentedOption<int>(
            value: 1,
            label: 'Light',
            icon: IconAsset.sun,
            caption: '10 XP',
          ),
          SegmentedOption<int>(value: 2, label: 'Dark', icon: IconAsset.moon),
        ],
        selected: 1,
        onChanged: (_) {},
      ),
    );
    expect(find.byType(AppIcon), findsNWidgets(2));
    expect(find.text('10 XP'), findsOneWidget);
  });
}
