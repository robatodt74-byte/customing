import 'package:customing/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> start(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(const CustomingApp());
    for (final bike in bikeModels.values) {
      await rootBundle.loadString(bike.manifest);
    }
    await tester.pump();
  });
  await tester.pumpAndSettle();
}

Future<void> choose(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.tap(target);
  if (key.startsWith('model-')) {
    await tester.runAsync(() async {
      await rootBundle.loadString(bikeModels[key.substring(6)]!.manifest);
      await tester.pump();
    });
  }
  await tester.pumpAndSettle();
}

void main() {
  for (final model in bikeModels.keys) {
    testWidgets('$model has its own bike and all customization controls', (
      tester,
    ) async {
      await start(tester);
      await choose(tester, 'model-$model');
      expect(find.byKey(ValueKey('image-$model-chassis')), findsOneWidget);
      final image = tester.widget<Image>(
        find.byKey(ValueKey('image-$model-chassis')),
      );
      final path = (image.image as AssetImage).assetName;
      expect(
        path,
        model == 'cb223s'
            ? 'assets/bike/chassis.png'
            : model == 'vstrom250'
            ? 'assets/bike/vstrom/chassis.png'
            : 'assets/bike/rebel/chassis-icon-v3.png',
      );
      for (final exhaust in exhaustLabels.keys) {
        await choose(tester, 'exhaust-$exhaust');
        expect(
          find.byKey(ValueKey('image-$model-exhaust-$exhaust')),
          findsOneWidget,
        );
      }
      for (final color in tankColors.keys) {
        await choose(tester, 'tank-$color');
        expect(
          find.byKey(ValueKey('image-$model-tank-$color')),
          findsOneWidget,
        );
      }
      for (final part in ['rear', 'side']) {
        for (final value in ['box', 'none']) {
          await choose(tester, '$part-$value');
          expect(
            find.byKey(ValueKey('image-$model-$part-box')),
            value == 'box' ? findsOneWidget : findsNothing,
          );
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('switching bikes restores independent customization', (
    tester,
  ) async {
    await start(tester);
    await choose(tester, 'tank-red');
    await choose(tester, 'exhaust-titanium');
    await choose(tester, 'rear-box');
    await choose(tester, 'model-vstrom250');
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('tank-black')))
          .selected,
      isTrue,
    );
    await choose(tester, 'tank-yellow');
    await choose(tester, 'side-box');
    await choose(tester, 'model-rebel250');
    await choose(tester, 'tank-blue');
    await choose(tester, 'model-cb223s');
    expect(find.byKey(const ValueKey('image-cb223s-tank-red')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('image-cb223s-exhaust-titanium')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('image-cb223s-rear-box')), findsOneWidget);
    expect(find.byKey(const ValueKey('image-cb223s-side-box')), findsNothing);
    await choose(tester, 'model-vstrom250');
    expect(
      find.byKey(const ValueKey('image-vstrom250-tank-yellow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('image-vstrom250-side-box')),
      findsOneWidget,
    );
    await choose(tester, 'model-rebel250');
    expect(
      find.byKey(const ValueKey('image-rebel250-tank-blue')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('price total follows model and selected parts', (tester) async {
    await start(tester);
    await choose(tester, 'model-rebel250');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('price-total'))).data,
      '参考合計 638,000 円',
    );
    await choose(tester, 'exhaust-titanium');
    await choose(tester, 'rear-box');
    await choose(tester, 'side-box');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('price-total'))).data,
      '参考合計 743,600 円',
    );
    await choose(tester, 'model-vstrom250');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('price-total'))).data,
      '参考合計 685,300 円',
    );
    await choose(tester, 'model-rebel250');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('price-total'))).data,
      '参考合計 743,600 円',
    );
    expect(find.byKey(const ValueKey('price-exclusions')), findsOneWidget);
  });

  for (final width in [320.0, 375.0, 414.0, 768.0]) {
    testWidgets('all bikes fit at width $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await start(tester);
      for (final model in bikeModels.keys) {
        await choose(tester, 'model-$model');
        expect(find.byType(ChoiceChip), findsNWidgets(18));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
