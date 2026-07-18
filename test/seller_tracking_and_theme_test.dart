import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/app/app_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('theme button toggles between light and dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(AppHomePage))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const Key('theme-toggle-button')));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(AppHomePage))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('theme-toggle-button')));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(AppHomePage))).brightness,
      Brightness.light,
    );
  });

  testWidgets('adds a seller from the seller tracking form', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Satıcı Takibe Al'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pump();
    expect(find.text('Bu alan boş olamaz'), findsNWidgets(3));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Satıcı adı'),
      'Yeni Mağaza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Satıcı linki'),
      'https://example.com/yeni-magaza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pazaryeri/Site'),
      'Örnek Pazar',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Mağaza'), findsOneWidget);
    expect(find.text('Pazaryeri: Örnek Pazar'), findsOneWidget);
    expect(find.text('Toplam ürün: 0'), findsOneWidget);
    expect(find.text('Yeni ürün: 0'), findsOneWidget);
  });
}
