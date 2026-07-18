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

  test('adding a seller persists and restores the seller list', () async {
    final storage = MemoryAppStorage();
    final appState = AppState(storage: storage);
    addTearDown(appState.dispose);
    await appState.initialize();
    final seller = SellerWatchItem(
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
}
