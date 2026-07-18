import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_check_result.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/domain/services/product_tracking_service.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/product_watch_detail_page.dart';

import 'helpers/memory_app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first successful check creates baseline and no alerts', () async {
    final product = _product(lastPrice: 0, previousPrice: 0, inStock: false);
    final storage = _storageWith(product);
    final appState = AppState(
      storage: storage,
      productTrackingService: _QueueProductTrackingService([
        _result(price: 1200, inStock: true),
      ]),
    );
    addTearDown(appState.dispose);
    await appState.initialize();

    final updated = await appState.checkWatchItemNow(product.id);

    expect(updated, isNotNull);
    expect(updated!.lastPrice, 1200);
    expect(updated.previousPrice, 0);
    expect(updated.priceChanged, isFalse);
    expect(updated.inStock, isTrue);
    expect(updated.checkStatus, TrackingCheckStatus.success);
    expect(updated.alerts, isEmpty);
    expect(appState.alerts, isEmpty);
  });

  test('second check updates price change fields and persists data', () async {
    final product = _product(lastPrice: 1200, previousPrice: 0);
    final storage = _storageWith(product);
    final appState = AppState(
      storage: storage,
      productTrackingService: _QueueProductTrackingService([
        _result(price: 1350, inStock: true),
      ]),
    );
    addTearDown(appState.dispose);
    await appState.initialize();

    final updated = await appState.checkWatchItemNow(product.id);

    expect(updated!.previousPrice, 1200);
    expect(updated.lastPrice, 1350);
    expect(updated.priceChanged, isTrue);
    final storedProducts = jsonDecode(storage.watchItems!) as List<dynamic>;
    expect(storedProducts.first['lastPrice'], 1350);
    expect(storedProducts.first['previousPrice'], 1200);
  });

  test('price drop and price rise alerts are created', () async {
    final product = _product(lastPrice: 1500);
    final appState = await _stateWith(
      product,
      results: [
        _result(price: 1300, inStock: true),
        _result(price: 1600, inStock: true, minute: 1),
      ],
    );
    addTearDown(appState.dispose);

    await appState.checkWatchItemNow(product.id);
    await appState.checkWatchItemNow(product.id);

    expect(appState.watchItems.first.alerts.map((alert) => alert.title), [
      'Fiyat yükseldi',
      'Fiyat düştü',
    ]);
    expect(appState.alerts.map((alert) => alert.title), [
      'Fiyat yükseldi',
      'Fiyat düştü',
    ]);
    expect(appState.alerts.first.sourceType, 'product');
    expect(appState.alerts.first.sourceId, product.id);
    expect(appState.alerts.first.sourceName, product.productName);
  });

  test('stock alerts respect stock tracking setting', () async {
    final product = _product(lastPrice: 1500, inStock: false);
    final appState = await _stateWith(
      product,
      results: [
        _result(price: 1500, inStock: true),
        _result(price: 1500, inStock: false, minute: 1),
      ],
    );
    addTearDown(appState.dispose);

    await appState.checkWatchItemNow(product.id);
    await appState.checkWatchItemNow(product.id);

    expect(appState.alerts.map((alert) => alert.title), [
      'Stok bitti',
      'Stok geldi',
    ]);

    final disabledProduct = _product(
      id: 'product_disabled',
      lastPrice: 1500,
      inStock: false,
      stockTrackingEnabled: false,
    );
    final disabledState = await _stateWith(
      disabledProduct,
      results: [_result(price: 1500, inStock: true)],
    );
    addTearDown(disabledState.dispose);

    await disabledState.checkWatchItemNow(disabledProduct.id);

    expect(disabledState.alerts, isEmpty);
  });

  test(
    'target price alert is emitted only when crossing the threshold',
    () async {
      final product = _product(lastPrice: 1200, targetPrice: 1000);
      final appState = await _stateWith(
        product,
        results: [
          _result(price: 950, inStock: true),
          _result(price: 900, inStock: true, minute: 1),
        ],
      );
      addTearDown(appState.dispose);

      await appState.checkWatchItemNow(product.id);
      await appState.checkWatchItemNow(product.id);

      expect(
        appState.alerts
            .where((alert) => alert.title == 'Hedef fiyata ulaştı')
            .length,
        1,
      );
    },
  );

  test('error URL moves to failed state and keeps previous data', () async {
    final product = _product(
      productUrl: 'https://example.com/error-product',
      lastPrice: 1200,
      previousPrice: 1000,
      inStock: true,
    );
    final appState = await _stateWith(
      product,
      service: const _ThrowingProductTrackingService(),
    );
    addTearDown(appState.dispose);

    final updated = await appState.checkWatchItemNow(product.id);

    expect(updated!.checkStatus, TrackingCheckStatus.failed);
    expect(updated.lastCheckError, contains('Ürün bilgisi okunamadı'));
    expect(updated.lastPrice, 1200);
    expect(updated.previousPrice, 1000);
    expect(updated.inStock, isTrue);
    expect(updated.alerts, product.alerts);
  });

  test('second check is ignored while product is already checking', () async {
    final completer = Completer<ProductCheckResult>();
    final service = _CompleterProductTrackingService(completer);
    final product = _product(lastPrice: 1200);
    final appState = await _stateWith(product, service: service);
    addTearDown(appState.dispose);

    final first = appState.checkWatchItemNow(product.id);
    final second = await appState.checkWatchItemNow(product.id);

    expect(second!.checkStatus, TrackingCheckStatus.checking);
    expect(service.callCount, 1);

    completer.complete(_result(price: 1250, inStock: true));
    await first;
  });

  test(
    'deleted product is not restored when an in-flight check finishes',
    () async {
      final completer = Completer<ProductCheckResult>();
      final service = _CompleterProductTrackingService(completer);
      final product = _product(lastPrice: 1200);
      final storage = _storageWith(product);
      final appState = AppState(
        storage: storage,
        productTrackingService: service,
      );
      addTearDown(appState.dispose);
      await appState.initialize();

      final pendingCheck = appState.checkWatchItemNow(product.id);
      await appState.removeWatchItem(product.id);
      completer.complete(_result(price: 1100, inStock: true));

      final result = await pendingCheck;

      expect(result, isNull);
      expect(appState.watchItems, isEmpty);
      expect(appState.alerts, isEmpty);
      expect(jsonDecode(storage.watchItems!) as List<dynamic>, isEmpty);
    },
  );

  test(
    'removing an earlier product while checking updates the right item',
    () async {
      final firstProduct = _product(id: 'product_first', lastPrice: 900);
      final checkedProduct = _product(id: 'product_checked', lastPrice: 1200);
      final completer = Completer<ProductCheckResult>();
      final storage = _storageWithMany([firstProduct, checkedProduct]);
      final appState = AppState(
        storage: storage,
        productTrackingService: _CompleterProductTrackingService(completer),
      );
      addTearDown(appState.dispose);
      await appState.initialize();

      final pendingCheck = appState.checkWatchItemNow(checkedProduct.id);
      await appState.removeWatchItem(firstProduct.id);
      completer.complete(_result(price: 1300, inStock: true));

      final result = await pendingCheck;

      expect(result!.id, checkedProduct.id);
      expect(appState.watchItems, hasLength(1));
      expect(appState.watchItems.single.id, checkedProduct.id);
      expect(appState.watchItems.single.lastPrice, 1300);
    },
  );

  test(
    'in-flight edits keep current fields and use current source name and target',
    () async {
      final product = _product(
        productName: 'Eski Ürün',
        lastPrice: 1200,
        targetPrice: 900,
      );
      final completer = Completer<ProductCheckResult>();
      final appState = await _stateWith(
        product,
        service: _CompleterProductTrackingService(completer),
      );
      addTearDown(appState.dispose);

      final pendingCheck = appState.checkWatchItemNow(product.id);
      await appState.updateWatchItem(
        appState.watchItems.first.copyWith(
          productName: 'Güncel Ürün',
          productUrl: 'https://example.com/current',
          marketplaceName: 'Güncel Pazar',
          sellerName: 'Güncel Satıcı',
          targetPrice: 1100,
          stockTrackingEnabled: false,
          checkTimes: const ['18:00', '08:00'],
        ),
      );
      completer.complete(_result(price: 1050, inStock: false));

      final result = await pendingCheck;

      expect(result!.productName, 'Güncel Ürün');
      expect(result.productUrl, 'https://example.com/current');
      expect(result.marketplaceName, 'Güncel Pazar');
      expect(result.sellerName, 'Güncel Satıcı');
      expect(result.targetPrice, 1100);
      expect(result.stockTrackingEnabled, isFalse);
      expect(result.checkTimes, const ['08:00', '18:00']);
      expect(result.previousPrice, 1200);
      expect(result.lastPrice, 1050);
      expect(
        appState.alerts
            .where((alert) => alert.title == 'Hedef fiyata ulaştı')
            .length,
        1,
      );
      expect(
        appState.alerts.every((alert) => alert.sourceName == 'Güncel Ürün'),
        isTrue,
      );
      expect(
        appState.alerts.any((alert) => alert.title == 'Stok bitti'),
        isFalse,
      );
    },
  );

  test('failed in-flight check preserves current editable fields', () async {
    final product = _product(lastPrice: 1200, targetPrice: 900);
    final completer = Completer<ProductCheckResult>();
    final appState = await _stateWith(
      product,
      service: _CompleterProductTrackingService(completer),
    );
    addTearDown(appState.dispose);

    final pendingCheck = appState.checkWatchItemNow(product.id);
    await appState.updateWatchItem(
      appState.watchItems.first.copyWith(
        productName: 'Hata Sırasında Güncel',
        targetPrice: 1100,
        checkTimes: const ['07:00'],
      ),
    );
    completer.completeError(Exception('Geçici servis hatası.'));

    final result = await pendingCheck;

    expect(result!.checkStatus, TrackingCheckStatus.failed);
    expect(result.productName, 'Hata Sırasında Güncel');
    expect(result.targetPrice, 1100);
    expect(result.checkTimes, const ['07:00']);
    expect(result.lastPrice, 1200);
    expect(result.lastCheckError, 'Geçici servis hatası.');
  });

  test(
    'product and alert persistence are updated after alert creation',
    () async {
      final product = _product(lastPrice: 1500);
      final storage = _storageWith(product);
      final appState = AppState(
        storage: storage,
        productTrackingService: _QueueProductTrackingService([
          _result(price: 1400, inStock: true),
        ]),
      );
      addTearDown(appState.dispose);
      await appState.initialize();

      await appState.checkWatchItemNow(product.id);

      final storedProducts = jsonDecode(storage.watchItems!) as List<dynamic>;
      final storedAlerts = jsonDecode(storage.alerts!) as List<dynamic>;
      expect(storedProducts.first['alerts'], isNotEmpty);
      expect(storedAlerts.single['title'], 'Fiyat düştü');
    },
  );

  testWidgets('detail button shows checking and success states', (
    tester,
  ) async {
    final completer = Completer<ProductCheckResult>();
    final appState = await _stateWith(
      _product(lastPrice: 1200),
      service: _CompleterProductTrackingService(completer),
    );
    addTearDown(appState.dispose);

    await tester.pumpWidget(_detailHarness(appState));
    await tester.tap(find.text('Şimdi kontrol et'));
    await tester.pump();

    expect(find.text('Kontrol ediliyor'), findsOneWidget);
    final checkingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Kontrol ediliyor'),
    );
    final editButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.edit_outlined),
    );
    final deleteButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.delete_outline),
    );
    expect(checkingButton.onPressed, isNull);
    expect(editButton.onPressed, isNull);
    expect(deleteButton.onPressed, isNull);

    completer.complete(_result(price: 1250, inStock: true));
    await tester.pumpAndSettle();

    expect(find.text('Ürün kontrol edildi.'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.edit_outlined),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.delete_outline),
          )
          .onPressed,
      isNotNull,
    );
    await tester.scrollUntilVisible(
      find.text('Kontrol başarılı'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kontrol başarılı'), findsOneWidget);
    expect(find.text('1250 TL'), findsOneWidget);
  });

  testWidgets('detail button shows failure state', (tester) async {
    final appState = await _stateWith(
      _product(productUrl: 'https://example.com/error'),
      service: const _ThrowingProductTrackingService(),
    );
    addTearDown(appState.dispose);

    await tester.pumpWidget(_detailHarness(appState));
    await tester.tap(find.text('Şimdi kontrol et'));
    await tester.pumpAndSettle();

    expect(find.text('Ürün kontrol edilemedi.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kontrol başarısız'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kontrol başarısız'), findsOneWidget);
    expect(find.text('Kontrol hatası'), findsOneWidget);
  });

  test('missing or invalid product checkTimes falls back to defaults', () {
    expect(ProductWatchItem.fromJson(const {}).checkTimes, defaultCheckTimes);
    expect(
      ProductWatchItem.fromJson(const {
        'checkTimes': ['99:99', 'broken'],
      }).checkTimes,
      defaultCheckTimes,
    );
  });
}

ProductWatchItem _product({
  String id = 'product_manual',
  String productName = 'Manuel Ürün',
  String productUrl = 'https://example.com/product',
  int lastPrice = 0,
  int previousPrice = 0,
  int? targetPrice,
  bool inStock = true,
  bool stockTrackingEnabled = true,
}) {
  return ProductWatchItem(
    id: id,
    productName: productName,
    productUrl: productUrl,
    checkTimes: defaultCheckTimes,
    alerts: const [],
    marketplaceName: 'Test Pazar',
    sellerName: 'Test Satıcı',
    lastPrice: lastPrice,
    previousPrice: previousPrice,
    targetPrice: targetPrice,
    checkStatus: lastPrice == 0
        ? TrackingCheckStatus.neverChecked
        : TrackingCheckStatus.success,
    lastCheckedAt: lastPrice == 0 ? null : DateTime(2026, 7, 17, 10),
    lastCheckError: null,
    priceChanged: false,
    stockTrackingEnabled: stockTrackingEnabled,
    inStock: inStock,
  );
}

ProductCheckResult _result({
  required int price,
  required bool inStock,
  int minute = 0,
}) {
  return ProductCheckResult(
    price: price,
    inStock: inStock,
    checkedAt: DateTime(2026, 7, 18, 12, minute),
  );
}

MemoryAppStorage _storageWith(ProductWatchItem product) {
  return _storageWithMany([product]);
}

MemoryAppStorage _storageWithMany(List<ProductWatchItem> products) {
  return MemoryAppStorage()
    ..watchItems = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    )
    ..sellerItems = '[]'
    ..alerts = '[]';
}

Future<AppState> _stateWith(
  ProductWatchItem product, {
  List<ProductCheckResult> results = const [],
  ProductTrackingService? service,
}) async {
  final appState = AppState(
    storage: _storageWith(product),
    productTrackingService: service ?? _QueueProductTrackingService(results),
  );
  await appState.initialize();
  return appState;
}

Widget _detailHarness(AppState appState) {
  return MaterialApp(
    home: ProductWatchDetailPage(
      item: appState.watchItems.first,
      appState: appState,
    ),
  );
}

class _QueueProductTrackingService implements ProductTrackingService {
  _QueueProductTrackingService(this.results);

  final List<ProductCheckResult> results;
  var _index = 0;

  @override
  Future<ProductCheckResult> checkProduct(ProductWatchItem item) async {
    return results[_index++];
  }
}

class _CompleterProductTrackingService implements ProductTrackingService {
  _CompleterProductTrackingService(this.completer);

  final Completer<ProductCheckResult> completer;
  var callCount = 0;

  @override
  Future<ProductCheckResult> checkProduct(ProductWatchItem item) {
    callCount += 1;
    return completer.future;
  }
}

class _ThrowingProductTrackingService implements ProductTrackingService {
  const _ThrowingProductTrackingService();

  @override
  Future<ProductCheckResult> checkProduct(ProductWatchItem item) async {
    throw Exception('Ürün bilgisi okunamadı.');
  }
}
