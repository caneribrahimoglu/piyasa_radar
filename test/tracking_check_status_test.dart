import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/widgets/seller_watch_card.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/presentation/widgets/product_watch_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('product cards show all check status labels', (tester) async {
    final baseItem = const FakeWatchlistRepository().getWatchItems().first;
    final items = [
      baseItem.copyWith(checkStatus: TrackingCheckStatus.neverChecked),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.checking),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.success),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.failed),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (final item in items)
                ProductWatchCard(item: item, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Henüz kontrol edilmedi'), findsOneWidget);
    expect(find.text('Kontrol ediliyor'), findsOneWidget);
    expect(find.text('Kontrol başarılı'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kontrol başarısız'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kontrol başarısız'), findsOneWidget);
  });

  testWidgets('seller cards show all check status labels', (tester) async {
    final baseItem = const FakeSellerTrackingRepository()
        .getSellerWatchItems()
        .first;
    final items = [
      baseItem.copyWith(checkStatus: TrackingCheckStatus.neverChecked),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.checking),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.success),
      baseItem.copyWith(checkStatus: TrackingCheckStatus.failed),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (final item in items)
                SellerWatchCard(item: item, onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Henüz kontrol edilmedi'), findsOneWidget);
    expect(find.text('Kontrol ediliyor'), findsOneWidget);
    expect(find.text('Kontrol başarılı'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kontrol başarısız'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kontrol başarısız'), findsOneWidget);
  });

  testWidgets('failed product detail shows check error', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Samsung 980 Pro 1TB'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Kontrol hatası'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kontrol durumu'), findsOneWidget);
    expect(find.text('Kontrol başarısız'), findsOneWidget);
    expect(find.text('Kontrol hatası'), findsOneWidget);
    expect(find.text('Pazaryeri stok bilgisi okunamadı.'), findsOneWidget);
  });

  testWidgets('never checked seller detail shows unchecked text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CepDükkanı'));
    await tester.pumpAndSettle();

    expect(find.text('Kontrol durumu'), findsOneWidget);
    expect(find.text('Henüz kontrol edilmedi'), findsWidgets);
    expect(find.text('Kontrol hatası'), findsNothing);
  });
}
