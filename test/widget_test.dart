import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('shows dashboard summary on app start', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();

    expect(find.text('Piyasa Radar'), findsOneWidget);
    expect(find.text('Özet'), findsNWidgets(2));
    expect(find.text('Ürün Takibi'), findsOneWidget);
    expect(find.text('Satıcı Takibi'), findsOneWidget);
    expect(find.text('Takip edilen ürün'), findsOneWidget);
    expect(find.text('Takip edilen satıcı'), findsOneWidget);
    expect(find.text('Aktif alert'), findsOneWidget);
    expect(find.text('Yeni ürün'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('shows fake watchlist products', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    expect(find.text('Piyasa Radar'), findsOneWidget);
    expect(find.text('Özet'), findsOneWidget);
    expect(find.text('Ürün Takibi'), findsOneWidget);
    expect(find.text('Satıcı Takibi'), findsOneWidget);
    expect(find.text('Logitech MX Master 3S'), findsOneWidget);
    expect(find.text('Samsung 980 Pro 1TB'), findsOneWidget);
    expect(find.text('iPhone 15 128GB'), findsOneWidget);
    expect(find.text('Pazaryeri: Trendyol'), findsOneWidget);
    expect(find.text('Pazaryeri: Hepsiburada'), findsOneWidget);
    expect(find.text('Pazaryeri: N11'), findsOneWidget);
    expect(find.text('Satıcı: TeknolojiPlus'), findsOneWidget);
    expect(find.text('Satıcı: DepoMarket'), findsOneWidget);
    expect(find.text('Satıcı: CepDükkanı'), findsOneWidget);
    expect(find.text('Son kontrol: 17.07.2026 14:30'), findsOneWidget);
    expect(find.text('Son kontrol: 17.07.2026 13:10'), findsOneWidget);
    expect(find.text('Son kontrol: 16.07.2026 21:45'), findsOneWidget);
    expect(find.text('3299 TL'), findsOneWidget);
    expect(find.text('3499 TL'), findsOneWidget);
    expect(find.text('2899 TL'), findsOneWidget);
    expect(find.text('2799 TL'), findsOneWidget);
    expect(find.text('48999 TL'), findsNWidgets(2));
    expect(find.text('Fiyat değişti'), findsNWidgets(2));
    expect(find.text('Stokta yok'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Detay'), findsNWidgets(3));
    expect(find.text('Takip edilen ürün yok'), findsNothing);
    expect(
      find.text('https://www.trendyol.com/logitech-mx-master-3s'),
      findsNothing,
    );
  });

  testWidgets('shows seller tracking tab with fake sellers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();

    expect(find.text('Satıcı Takibi'), findsNWidgets(2));
    expect(find.text('TeknolojiPlus'), findsOneWidget);
    expect(find.text('DepoMarket'), findsOneWidget);
    expect(find.text('CepDükkanı'), findsOneWidget);
    expect(find.text('Pazaryeri: Trendyol'), findsOneWidget);
    expect(find.text('Pazaryeri: Hepsiburada'), findsOneWidget);
    expect(find.text('Pazaryeri: N11'), findsOneWidget);
    expect(find.text('Toplam ürün: 128'), findsOneWidget);
    expect(find.text('Yeni ürün: 6'), findsOneWidget);
    expect(find.text('Son kontrol: 17.07.2026 14:20'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Detay'), findsNWidgets(3));
  });

  testWidgets('opens seller tracking detail page from detail button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Detay').first);
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Satıcı Detayı'), findsOneWidget);
    expect(find.text('TeknolojiPlus'), findsOneWidget);
    expect(find.text('Pazaryeri'), findsOneWidget);
    expect(find.text('Trendyol'), findsOneWidget);
    expect(find.text('Satıcı linki'), findsOneWidget);
    expect(
      find.text('https://www.trendyol.com/magaza/teknolojiplus'),
      findsOneWidget,
    );
    expect(find.text('Toplam ürün sayısı'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Yeni ürün sayısı'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Son kontrol zamanı'), findsOneWidget);
    expect(find.text('17.07.2026 14:20'), findsOneWidget);
    expect(find.text('Ürün Listesi'), findsOneWidget);
    expect(find.text('Logitech MX Keys S'), findsOneWidget);
    expect(find.text('4299 TL'), findsOneWidget);
    expect(find.text('17.07.2026 14:18'), findsNWidgets(2));
    expect(find.text('Yeni ürün'), findsOneWidget);
    expect(find.text('Logitech Lift Mouse'), findsOneWidget);
    expect(find.text('1899 TL'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Alert Geçmişi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alert Geçmişi'), findsOneWidget);
    expect(find.text('Yeni ürün tespit edildi'), findsOneWidget);
    expect(
      find.text('Logitech MX Keys S satıcı listesine eklendi.'),
      findsOneWidget,
    );
    expect(find.text('Ürün fiyatı değişti'), findsOneWidget);
    expect(
      find.text(
        'Logitech Lift Mouse fiyatı 1999 TL seviyesinden 1899 TL seviyesine indi.',
      ),
      findsOneWidget,
    );
    expect(find.text('17.07.2026 14:18'), findsNWidgets(2));
    expect(find.text('16.07.2026 10:05'), findsNWidgets(2));

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Satıcı Takibi'), findsNWidgets(2));
    expect(find.text('DepoMarket'), findsOneWidget);
  });

  testWidgets('opens seller tracking detail page from card body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TeknolojiPlus'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Satıcı Detayı'), findsOneWidget);
    expect(find.text('TeknolojiPlus'), findsOneWidget);
    expect(find.text('Satıcı linki'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Satıcı Takibi'), findsNWidgets(2));
  });

  testWidgets('opens product watch detail page from card body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logitech MX Master 3S'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Logitech MX Master 3S'), findsNWidgets(2));
    expect(find.text('Ürün linki'), findsOneWidget);
    expect(
      find.text('https://www.trendyol.com/logitech-mx-master-3s'),
      findsOneWidget,
    );
    expect(find.text('Kontrol saatleri'), findsOneWidget);
    expect(find.text('09:00, 14:00, 20:00'), findsOneWidget);
    expect(find.text('Pazaryeri/Site'), findsOneWidget);
    expect(find.text('Trendyol'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Piyasa Radar'), findsOneWidget);
  });

  testWidgets('opens product watch detail page from detail button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Detay').first);
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Logitech MX Master 3S'), findsNWidgets(2));
    expect(find.text('Ürün linki'), findsOneWidget);
    expect(
      find.text('https://www.trendyol.com/logitech-mx-master-3s'),
      findsOneWidget,
    );
    expect(find.text('Kontrol saatleri'), findsOneWidget);
    expect(find.text('09:00, 14:00, 20:00'), findsOneWidget);
    expect(find.text('Pazaryeri/Site'), findsOneWidget);
    expect(find.text('Trendyol'), findsOneWidget);
    expect(find.text('Satıcı adı'), findsOneWidget);
    expect(find.text('TeknolojiPlus'), findsOneWidget);
    expect(find.text('Son fiyat'), findsOneWidget);
    expect(find.text('3299 TL'), findsOneWidget);
    expect(find.text('Önceki fiyat'), findsOneWidget);
    expect(find.text('3499 TL'), findsOneWidget);
    expect(find.text('Son kontrol zamanı'), findsOneWidget);
    expect(find.text('17.07.2026 14:30'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Alert Geçmişi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Stok durumu'), findsOneWidget);
    expect(find.text('Stokta'), findsOneWidget);
    expect(find.text('Fiyat durumu'), findsOneWidget);
    expect(find.text('Fiyat değişti'), findsOneWidget);
    expect(find.text('Alert Geçmişi'), findsOneWidget);
    expect(find.text('Fiyat düştü'), findsOneWidget);
    expect(
      find.text('Ürün fiyatı 3499 TL seviyesinden 3299 TL seviyesine indi.'),
      findsOneWidget,
    );
    expect(find.text('17.07.2026 14:35'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Piyasa Radar'), findsOneWidget);
    expect(find.text('Samsung 980 Pro 1TB'), findsOneWidget);
  });

  testWidgets('adds product from form and returns to watchlist', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Ürün Takibe Al'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ürün Takibe Al'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün adı'),
      'PlayStation 5 Slim',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün linki'),
      'https://example.com/ps5-slim',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pazaryeri/Site'),
      'Amazon',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hedef fiyat'),
      '19999',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Piyasa Radar'), findsOneWidget);
    expect(find.text('Ürün takibe eklendi.'), findsOneWidget);

    expect(find.text('PlayStation 5 Slim'), findsOneWidget);
    expect(find.text('Pazaryeri: Amazon'), findsOneWidget);
    expect(find.text('Satıcı: Bilinmeyen satıcı'), findsOneWidget);
    expect(find.text('19999 TL'), findsNWidgets(2));
    expect(find.text('https://example.com/ps5-slim'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Detay'), findsWidgets);

    await tester.tap(find.text('PlayStation 5 Slim'));
    await tester.pumpAndSettle();

    expect(find.text('Ürün linki'), findsOneWidget);
    expect(find.text('https://example.com/ps5-slim'), findsOneWidget);
    expect(find.text('Kontrol saatleri'), findsOneWidget);
    expect(find.text('09:00, 14:00, 20:00'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Alert Geçmişi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alert Geçmişi'), findsOneWidget);
    expect(find.text('Henüz alert yok'), findsOneWidget);
  });

  testWidgets('validates required add product form fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Ürün Takibe Al'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pump();

    expect(find.text('Bu alan boş olamaz'), findsNWidgets(3));
    expect(find.text('Piyasa Radar'), findsNothing);
  });

  testWidgets('cancels and confirms removing a tracked product', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logitech MX Master 3S'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Takipten çıkar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Bu ürünü takipten çıkarmak istediğinize emin misiniz?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.text('Logitech MX Master 3S'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Takipten çıkar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Takipten Çıkar'));
    await tester.pumpAndSettle();

    expect(find.text('Ürün takipten çıkarıldı.'), findsOneWidget);
    expect(find.text('Logitech MX Master 3S'), findsNothing);

    await tester.tap(find.text('Özet'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
