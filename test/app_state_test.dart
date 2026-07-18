import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';

import 'helpers/memory_app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('first launch loads the fake repository data', () async {
    final appState = AppState(storage: MemoryAppStorage());
    addTearDown(appState.dispose);

    await appState.initialize();

    expect(appState.watchItems, hasLength(3));
    expect(appState.sellerItems, hasLength(3));
    expect(appState.alerts, hasLength(7));
    expect(appState.isInitialized, isTrue);
  });

  test('adding a product persists and restores the product list', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final item = const FakeWatchlistRepository().getWatchItems().first;

    await appState.addWatchItem(item);

    expect(jsonDecode(storage.watchItems!) as List, hasLength(4));

    final restoredState = AppState(storage: storage);
    addTearDown(restoredState.dispose);
    await restoredState.initialize();
    expect(restoredState.watchItems, hasLength(4));
    expect(restoredState.watchItems.last.productName, item.productName);
  });

  test(
    'updating a product persists it and updates related alert source names',
    () async {
      final storage = MemoryAppStorage();
      final appState = AppState(storage: storage);
      addTearDown(appState.dispose);
      await appState.initialize();

      final original = appState.watchItems.first;
      final updated = original.copyWith(productName: 'Güncel Ürün');

      await appState.updateWatchItem(updated);

      expect(appState.watchItems.first.productName, 'Güncel Ürün');
      expect(
        appState.alerts
            .where(
              (alert) =>
                  alert.sourceType == 'product' &&
                  alert.sourceId == original.id,
            )
            .every((alert) => alert.sourceName == 'Güncel Ürün'),
        isTrue,
      );

      final storedProducts = jsonDecode(storage.watchItems!) as List<dynamic>;
      expect(storedProducts.first['productName'], 'Güncel Ürün');

      final storedAlerts = jsonDecode(storage.alerts!) as List<dynamic>;
      expect(
        storedAlerts
            .where(
              (alert) =>
                  alert['sourceType'] == 'product' &&
                  alert['sourceId'] == original.id,
            )
            .every((alert) => alert['sourceName'] == 'Güncel Ürün'),
        isTrue,
      );
    },
  );

  test('adding a seller persists and restores the seller list', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final seller = SellerWatchItem(
      id: 'seller_new',
      sellerName: 'Yeni Satıcı',
      marketplaceName: 'Pazar',
      sellerUrl: 'https://example.com',
      totalProducts: 0,
      newProductsCount: 0,
      lastCheckedAt: DateTime(2026),
      products: const [],
      alerts: const [],
    );

    await appState.addSellerItem(seller);

    expect(jsonDecode(storage.sellerItems!) as List, hasLength(4));

    final restoredState = AppState(storage: storage);
    addTearDown(restoredState.dispose);
    await restoredState.initialize();
    expect(restoredState.sellerItems.last.sellerName, 'Yeni Satıcı');
  });

  test(
    'updating a seller persists it and updates related alert source names',
    () async {
      final storage = MemoryAppStorage();
      final appState = AppState(storage: storage);
      addTearDown(appState.dispose);
      await appState.initialize();

      final original = appState.sellerItems.first;
      final updated = original.copyWith(sellerName: 'Güncel Satıcı');

      await appState.updateSellerItem(updated);

      expect(appState.sellerItems.first.sellerName, 'Güncel Satıcı');
      expect(
        appState.alerts
            .where(
              (alert) =>
                  alert.sourceType == 'seller' && alert.sourceId == original.id,
            )
            .every((alert) => alert.sourceName == 'Güncel Satıcı'),
        isTrue,
      );

      final storedSellers = jsonDecode(storage.sellerItems!) as List<dynamic>;
      expect(storedSellers.first['sellerName'], 'Güncel Satıcı');
    },
  );

  test('updating an unknown id is safe and leaves storage untouched', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();

    await appState.updateWatchItem(
      appState.watchItems.first.copyWith(id: 'missing_product'),
    );
    await appState.updateSellerItem(
      appState.sellerItems.first.copyWith(id: 'missing_seller'),
    );

    expect(appState.watchItems, hasLength(3));
    expect(appState.sellerItems, hasLength(3));
    expect(storage.watchItems, isNull);
    expect(storage.sellerItems, isNull);
  });

  test('marking an alert read persists and restores its state', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final alertId = appState.alerts.first.id;

    await appState.markAlertAsRead(alertId);
    await appState.markAlertAsRead(alertId);

    final storedAlerts = jsonDecode(storage.alerts!) as List<dynamic>;
    expect((storedAlerts.first as Map<String, dynamic>)['isRead'], isTrue);

    final restoredState = AppState(storage: storage);
    addTearDown(restoredState.dispose);
    await restoredState.initialize();
    expect(restoredState.alerts.first.isRead, isTrue);
  });

  test('corrupt JSON falls back to fake data without throwing', () async {
    final storage = MemoryAppStorage()
      ..watchItems = '{broken'
      ..sellerItems = 'not-json'
      ..alerts = '42';
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);

    await appState.initialize();

    expect(appState.watchItems, hasLength(3));
    expect(appState.sellerItems, hasLength(3));
    expect(appState.alerts, hasLength(7));
  });

  test('theme selection is persisted and restored', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();

    await appState.toggleTheme();
    final selectedTheme = appState.themeMode;

    expect(storage.themeMode, selectedTheme.name);
    expect(selectedTheme, isNot(ThemeMode.system));

    final restoredState = AppState(storage: storage);
    addTearDown(restoredState.dispose);
    await restoredState.initialize();
    expect(restoredState.themeMode, selectedTheme);
  });

  test('exposed state lists cannot be modified', () async {
    final appState = AppState(storage: MemoryAppStorage());
    addTearDown(appState.dispose);
    await appState.initialize();

    expect(
      () => appState.watchItems.add(appState.watchItems.first),
      throwsUnsupportedError,
    );
  });

  test('removing a product persists lists and removes its alerts', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final product = appState.watchItems.first;
    final relatedAlertCount = appState.alerts
        .where((alert) => alert.sourceId == product.id)
        .length;

    await appState.removeWatchItem(product.id);
    await appState.removeWatchItem('missing_product');

    expect(appState.watchItems.any((item) => item.id == product.id), isFalse);
    expect(appState.alerts, hasLength(7 - relatedAlertCount));
    expect(jsonDecode(storage.watchItems!) as List, hasLength(2));
    expect(
      jsonDecode(storage.alerts!) as List,
      hasLength(7 - relatedAlertCount),
    );

    final restoredState = AppState(storage: storage);
    addTearDown(restoredState.dispose);
    await restoredState.initialize();
    expect(
      restoredState.watchItems.any((item) => item.id == product.id),
      isFalse,
    );
  });

  test('removing a seller persists lists and removes its alerts', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final seller = appState.sellerItems.first;
    final relatedAlertCount = appState.alerts
        .where((alert) => alert.sourceId == seller.id)
        .length;

    await appState.removeSellerItem(seller.id);
    await appState.removeSellerItem('missing_seller');

    expect(appState.sellerItems.any((item) => item.id == seller.id), isFalse);
    expect(appState.alerts, hasLength(7 - relatedAlertCount));
    expect(jsonDecode(storage.sellerItems!) as List, hasLength(2));
    expect(
      jsonDecode(storage.alerts!) as List,
      hasLength(7 - relatedAlertCount),
    );
  });
}
