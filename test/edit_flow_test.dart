import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/pages/add_seller_watch_page.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/add_product_watch_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ProductEditHarness extends StatefulWidget {
  const _ProductEditHarness({required this.item});

  final ProductWatchItem item;

  @override
  State<_ProductEditHarness> createState() => _ProductEditHarnessState();
}

class _ProductEditHarnessState extends State<_ProductEditHarness> {
  ProductWatchItem? result;

  Future<void> _openForm(BuildContext navigatorContext) async {
    final item = await Navigator.of(navigatorContext).push<ProductWatchItem>(
      MaterialPageRoute(
        builder: (context) => AddProductWatchPage(initialItem: widget.item),
      ),
    );
    if (item != null) setState(() => result = item);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => _openForm(context),
            child: const Text('Ürün düzenle'),
          ),
        ),
      ),
    );
  }
}

class _SellerEditHarness extends StatefulWidget {
  const _SellerEditHarness({required this.item});

  final SellerWatchItem item;

  @override
  State<_SellerEditHarness> createState() => _SellerEditHarnessState();
}

class _SellerEditHarnessState extends State<_SellerEditHarness> {
  SellerWatchItem? result;

  Future<void> _openForm(BuildContext navigatorContext) async {
    final item = await Navigator.of(navigatorContext).push<SellerWatchItem>(
      MaterialPageRoute(
        builder: (context) => AddSellerWatchPage(initialItem: widget.item),
      ),
    );
    if (item != null) setState(() => result = item);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => _openForm(context),
            child: const Text('Satıcı düzenle'),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('product edit form shows initial values', (tester) async {
    final item = const FakeWatchlistRepository().getWatchItems().first;

    await tester.pumpWidget(
      MaterialApp(home: AddProductWatchPage(initialItem: item)),
    );

    expect(find.text('Ürün Takibini Düzenle'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, item.productName),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, item.productUrl), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, item.marketplaceName),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, item.sellerName), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '3000'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kontrol saatleri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('14:00'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Güncelle'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Güncelle'), findsOneWidget);
  });

  testWidgets(
    'product edit can clear target price and preserves tracking data',
    (tester) async {
      final item = const FakeWatchlistRepository().getWatchItems().first;

      await tester.pumpWidget(_ProductEditHarness(item: item));
      await tester.tap(find.text('Ürün düzenle'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, item.productName),
        'Güncel Ürün',
      );
      await tester.enterText(find.widgetWithText(TextFormField, '3000'), '');
      await tester.scrollUntilVisible(
        find.text('Güncelle'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Güncelle'));
      await tester.pumpAndSettle();

      final result = tester
          .state<_ProductEditHarnessState>(find.byType(_ProductEditHarness))
          .result!;

      expect(result.id, item.id);
      expect(result.productName, 'Güncel Ürün');
      expect(result.targetPrice, isNull);
      expect(result.checkTimes, item.checkTimes);
      expect(result.alerts, item.alerts);
      expect(result.lastPrice, item.lastPrice);
      expect(result.previousPrice, item.previousPrice);
      expect(result.lastCheckedAt, item.lastCheckedAt);
      expect(result.checkStatus, item.checkStatus);
      expect(result.lastCheckError, item.lastCheckError);
      expect(result.priceChanged, item.priceChanged);
      expect(result.inStock, item.inStock);
    },
  );

  testWidgets(
    'seller edit form shows initial values and preserves tracking data',
    (tester) async {
      final item = const FakeSellerTrackingRepository()
          .getSellerWatchItems()
          .first;

      await tester.pumpWidget(_SellerEditHarness(item: item));
      await tester.tap(find.text('Satıcı düzenle'));
      await tester.pumpAndSettle();

      expect(find.text('Satıcı Takibini Düzenle'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, item.sellerName),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, item.sellerUrl),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, item.marketplaceName),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Kontrol saatleri'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);

      await tester.ensureVisible(
        find.widgetWithText(TextFormField, item.sellerName),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, item.sellerName),
        'Güncel Satıcı',
      );
      await tester.scrollUntilVisible(
        find.text('Güncelle'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Güncelle'));
      await tester.pumpAndSettle();

      final result = tester
          .state<_SellerEditHarnessState>(find.byType(_SellerEditHarness))
          .result!;

      expect(result.id, item.id);
      expect(result.sellerName, 'Güncel Satıcı');
      expect(result.totalProducts, item.totalProducts);
      expect(result.newProductsCount, item.newProductsCount);
      expect(result.lastCheckedAt, item.lastCheckedAt);
      expect(result.checkStatus, item.checkStatus);
      expect(result.lastCheckError, item.lastCheckError);
      expect(result.products, item.products);
      expect(result.alerts, item.alerts);
    },
  );

  testWidgets('product form requires at least one check time', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddProductWatchPage()));

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

    await tester.scrollUntilVisible(
      find.text('Kontrol saatleri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index += 1) {
      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('En az bir kontrol saati seçmelisiniz.'), findsOneWidget);
  });

  testWidgets('seller form requires at least one check time', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddSellerWatchPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Satıcı adı'),
      'Test Satıcı',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Satıcı linki'),
      'https://example.com/seller',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pazaryeri/Site'),
      'Test Pazarı',
    );

    await tester.scrollUntilVisible(
      find.text('Kontrol saatleri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index += 1) {
      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('En az bir kontrol saati seçmelisiniz.'), findsOneWidget);
  });

  testWidgets('check time editor appears before the product form button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddProductWatchPage()));
    await tester.scrollUntilVisible(
      find.text('Kontrol saatleri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Kaydet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final editorTop = tester.getTopLeft(find.text('Kontrol saatleri')).dy;
    final buttonTop = tester.getTopLeft(find.text('Kaydet')).dy;

    expect(editorTop, lessThan(buttonTop));
  });

  testWidgets('product detail updates immediately after editing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logitech MX Master 3S'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Logitech MX Master 3S'),
      'Logitech MX Master Edit',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '3000'), '');
    await tester.scrollUntilVisible(
      find.text('Güncelle'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(find.text('Ürün takibi güncellendi.'), findsOneWidget);
    expect(find.text('Logitech MX Master Edit'), findsNWidgets(2));
    expect(find.text('Belirlenmedi'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Logitech MX Master Edit'), findsOneWidget);
  });

  testWidgets('seller detail updates immediately after editing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Satıcı Takibi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TeknolojiPlus'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'TeknolojiPlus'),
      'TeknolojiPlus Edit',
    );
    await tester.scrollUntilVisible(
      find.text('Güncelle'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(find.text('Satıcı takibi güncellendi.'), findsOneWidget);
    expect(find.text('TeknolojiPlus Edit'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('TeknolojiPlus Edit'), findsOneWidget);
  });
}
