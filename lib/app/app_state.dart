import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/storage/app_storage.dart';
import 'package:piyasa_radar/core/storage/shared_preferences_app_storage.dart';
import 'package:piyasa_radar/features/alerts/data/repositories/fake_alerts_repository.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

class AppState extends ChangeNotifier {
  AppState({
    AppStorage? storage,
    FakeWatchlistRepository watchlistRepository =
        const FakeWatchlistRepository(),
    FakeSellerTrackingRepository sellerTrackingRepository =
        const FakeSellerTrackingRepository(),
    FakeAlertsRepository? alertsRepository,
  }) : _storage = storage ?? SharedPreferencesAppStorage(),
       _watchlistRepository = watchlistRepository,
       _sellerTrackingRepository = sellerTrackingRepository,
       _alertsRepository =
           alertsRepository ??
           FakeAlertsRepository(
             watchlistRepository: watchlistRepository,
             sellerTrackingRepository: sellerTrackingRepository,
           );

  final AppStorage _storage;
  final FakeWatchlistRepository _watchlistRepository;
  final FakeSellerTrackingRepository _sellerTrackingRepository;
  final FakeAlertsRepository _alertsRepository;

  final List<ProductWatchItem> _watchItems = [];
  final List<SellerWatchItem> _sellerItems = [];
  final List<AlertSummaryItem> _alerts = [];
  Future<void>? _initialization;

  bool isInitialized = false;
  bool isLoading = false;
  ThemeMode themeMode = ThemeMode.system;

  UnmodifiableListView<ProductWatchItem> get watchItems =>
      UnmodifiableListView(_watchItems);
  UnmodifiableListView<SellerWatchItem> get sellerItems =>
      UnmodifiableListView(_sellerItems);
  UnmodifiableListView<AlertSummaryItem> get alerts =>
      UnmodifiableListView(_alerts);

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    isLoading = true;
    notifyListeners();

    _watchItems
      ..clear()
      ..addAll(await _loadWatchItems());
    _sellerItems
      ..clear()
      ..addAll(await _loadSellerItems());
    _alerts
      ..clear()
      ..addAll(await _loadAlerts());
    themeMode = await _loadThemeMode();

    isLoading = false;
    isInitialized = true;
    notifyListeners();
  }

  Future<List<ProductWatchItem>> _loadWatchItems() async {
    try {
      final value = await _storage.readWatchItems();
      if (value == null) return _watchlistRepository.getWatchItems();
      final decoded = jsonDecode(value);
      if (decoded is! List) throw const FormatException();
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                ProductWatchItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return _watchlistRepository.getWatchItems();
    }
  }

  Future<List<SellerWatchItem>> _loadSellerItems() async {
    try {
      final value = await _storage.readSellerItems();
      if (value == null) return _sellerTrackingRepository.getSellerWatchItems();
      final decoded = jsonDecode(value);
      if (decoded is! List) throw const FormatException();
      return decoded
          .whereType<Map>()
          .map(
            (item) => SellerWatchItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return _sellerTrackingRepository.getSellerWatchItems();
    }
  }

  Future<List<AlertSummaryItem>> _loadAlerts() async {
    try {
      final value = await _storage.readAlerts();
      if (value == null) return _alertsRepository.getAlerts();
      final decoded = jsonDecode(value);
      if (decoded is! List) throw const FormatException();
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                AlertSummaryItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return _alertsRepository.getAlerts();
    }
  }

  Future<ThemeMode> _loadThemeMode() async {
    try {
      final value = await _storage.readThemeMode();
      if (value == 'light') return ThemeMode.light;
      if (value == 'dark') return ThemeMode.dark;
    } catch (_) {
      // Keep the system theme when storage is unavailable.
    }
    return ThemeMode.system;
  }

  Future<void> addWatchItem(ProductWatchItem item) async {
    _watchItems.add(item);
    notifyListeners();
    await _persistWatchItems();
  }

  Future<void> addSellerItem(SellerWatchItem item) async {
    _sellerItems.add(item);
    notifyListeners();
    await _persistSellerItems();
  }

  Future<void> markAlertAsRead(String alertId) async {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1 || _alerts[index].isRead) return;

    _alerts[index] = _alerts[index].copyWith(isRead: true);
    notifyListeners();
    await _persistAlerts();
  }

  Future<void> toggleTheme() async {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _writeSafely(() => _storage.writeThemeMode(themeMode.name));
  }

  Future<void> _persistWatchItems() => _writeSafely(
    () => _storage.writeWatchItems(
      jsonEncode(_watchItems.map((item) => item.toJson()).toList()),
    ),
  );

  Future<void> _persistSellerItems() => _writeSafely(
    () => _storage.writeSellerItems(
      jsonEncode(_sellerItems.map((item) => item.toJson()).toList()),
    ),
  );

  Future<void> _persistAlerts() => _writeSafely(
    () => _storage.writeAlerts(
      jsonEncode(_alerts.map((item) => item.toJson()).toList()),
    ),
  );

  Future<void> _writeSafely(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {
      // State remains available in memory when persistence fails.
    }
  }
}
