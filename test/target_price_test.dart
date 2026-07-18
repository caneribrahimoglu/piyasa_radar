import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/add_product_watch_page.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/product_watch_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/memory_app_storage.dart';

class _AddProductHarness extends StatefulWidget {
  const _AddProductHarness();

  @override
  State<_AddProductHarness> createState() => _AddProductHarnessState();
}

class _AddProductHarnessState extends State<_AddProductHarness> {
  ProductWatchItem? result;

  Future<void> _openForm(BuildContext navigatorContext) async {
    final item = await Navigator.of(navigatorContext).push<ProductWatchItem>(
      MaterialPageRoute(builder: (context) => const AddProductWatchPage()),
    );
    if (item != null) setState(() => result = item);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              FilledButton(
                onPressed: () => _openForm(context),
                child: const Text('Formu aç'),
              ),
              if (result != null)
                Text(
                  'target:${result!.targetPrice},last:${result!.lastPrice},previous:${result!.previousPrice},status:${result!.checkStatus.name},checked:${result!.lastCheckedAt},error:${result!.lastCheckError}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> fillRequiredProductFields(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün adı'),
      'Test Ürünü',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün linki'),
      'https://example.com/product',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pazaryeri/Site'),
      'Test Pazarı',
    );
  }

  testWidgets('empty target price keeps target null and real prices zero', (
    tester,
  ) async {
    await tester.pumpWidget(const _AddProductHarness());
    await tester.tap(find.text('Formu aç'));
    await tester.pumpAndSettle();

    await fillRequiredProductFields(tester);
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'target:null,last:0,previous:0,status:${TrackingCheckStatus.neverChecked.name},checked:null,error:null',
      ),
      findsOneWidget,
    );
  });

  testWidgets('positive target price is saved separately from real prices', (
    tester,
  ) async {
    await tester.pumpWidget(const _AddProductHarness());
    await tester.tap(find.text('Formu aç'));
    await tester.pumpAndSettle();

    await fillRequiredProductFields(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hedef fiyat'),
      '3000',
    );
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'target:3000,last:0,previous:0,status:${TrackingCheckStatus.neverChecked.name},checked:null,error:null',
      ),
      findsOneWidget,
    );
  });

  testWidgets('zero and negative target prices are rejected', (tester) async {
    await tester.pumpWidget(const _AddProductHarness());
    await tester.tap(find.text('Formu aç'));
    await tester.pumpAndSettle();

    await fillRequiredProductFields(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hedef fiyat'),
      '0',
    );
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text("Hedef fiyat 0'dan büyük olmalı."), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hedef fiyat'),
      '-1',
    );
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text("Hedef fiyat 0'dan büyük olmalı."), findsOneWidget);
  });

  testWidgets('card shows target price only when it exists', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    expect(find.text('Hedef: 3000 TL'), findsOneWidget);
    expect(find.text('Hedef: 2600 TL'), findsOneWidget);
    expect(find.text('Hedef: null TL'), findsNothing);
  });

  testWidgets('detail shows missing and unchecked price states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _AddProductHarness());
    await tester.tap(find.text('Formu aç'));
    await tester.pumpAndSettle();
    await fillRequiredProductFields(tester);
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final item = tester
        .state<_AddProductHarnessState>(find.byType(_AddProductHarness))
        .result!;

    final appState = AppState(storage: MemoryAppStorage());
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProductWatchDetailPage(item: item, appState: appState),
                ),
              ),
              child: const Text('Detay aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Detay aç'));
    await tester.pumpAndSettle();

    expect(find.text('Hedef fiyat'), findsOneWidget);
    expect(find.text('Belirlenmedi'), findsOneWidget);
    expect(find.text('Henüz kontrol edilmedi'), findsWidgets);
    expect(find.text('Veri yok'), findsOneWidget);
  });
}
