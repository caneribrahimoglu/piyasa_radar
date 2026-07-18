import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/storage/app_storage.dart';
import 'package:piyasa_radar/core/storage/shared_preferences_app_storage.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/alerts/data/repositories/fake_alerts_repository.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/data/services/fake_product_tracking_service.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_check_result.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/domain/services/product_tracking_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    AppStorage? storage,
    FakeWatchlistRepository watchlistRepository =
        const FakeWatchlistRepository(),
    FakeSellerTrackingRepository sellerTrackingRepository =
        const FakeSellerTrackingRepository(),
    FakeAlertsRepository? alertsRepository,
    this.productTrackingService = const FakeProductTrackingService(),
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
  final ProductTrackingService productTrackingService;

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

  Future<void> updateWatchItem(ProductWatchItem item) async {
    final index = _watchItems.indexWhere(
      (watchItem) => watchItem.id == item.id,
    );
    if (index == -1) return;

    final previousItem = _watchItems[index];
    _watchItems[index] = item;
    final alertsChanged = previousItem.productName != item.productName
        ? _updateAlertSourceName(
            sourceType: 'product',
            sourceId: item.id,
            sourceName: item.productName,
            previousSourceName: previousItem.productName,
          )
        : false;

    notifyListeners();
    await Future.wait([
      _persistWatchItems(),
      if (alertsChanged) _persistAlerts(),
    ]);
  }

  Future<ProductWatchItem?> checkWatchItemNow(String id) async {
    final initialIndex = _watchItems.indexWhere((item) => item.id == id);
    if (initialIndex == -1) return null;

    final trackingSnapshot = _watchItems[initialIndex];
    final productId = trackingSnapshot.id;
    if (trackingSnapshot.checkStatus == TrackingCheckStatus.checking) {
      return trackingSnapshot;
    }

    _watchItems[initialIndex] = trackingSnapshot.copyWith(
      checkStatus: TrackingCheckStatus.checking,
      lastCheckError: null,
    );
    notifyListeners();

    try {
      final result = await productTrackingService.checkProduct(
        trackingSnapshot,
      );
      final currentIndex = _watchItems.indexWhere(
        (item) => item.id == productId,
      );
      if (currentIndex == -1) return null;

      final currentItem = _watchItems[currentIndex];
      final updatedItem = _buildSuccessfulProductCheck(
        currentItem: currentItem,
        trackingSnapshot: trackingSnapshot,
        result: result,
      );
      final newAlerts = _buildProductCheckAlerts(
        trackingSnapshot: trackingSnapshot,
        updatedItem: updatedItem,
        checkedAt: result.checkedAt,
      );

      _watchItems[currentIndex] = updatedItem.copyWith(
        alerts: [...newAlerts.productAlerts, ...updatedItem.alerts],
      );
      if (newAlerts.summaryAlerts.isNotEmpty) {
        _alerts
          ..addAll(newAlerts.summaryAlerts)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      notifyListeners();
      await Future.wait([
        _persistWatchItems(),
        if (newAlerts.summaryAlerts.isNotEmpty) _persistAlerts(),
      ]);
      return _watchItems[currentIndex];
    } catch (error) {
      final currentIndex = _watchItems.indexWhere(
        (item) => item.id == productId,
      );
      if (currentIndex == -1) return null;

      final failedItem = _watchItems[currentIndex].copyWith(
        checkStatus: TrackingCheckStatus.failed,
        lastCheckedAt: DateTime.now(),
        lastCheckError: _userFriendlyCheckError(error),
      );
      _watchItems[currentIndex] = failedItem;
      notifyListeners();
      await _persistWatchItems();
      return failedItem;
    }
  }

  Future<void> updateSellerItem(SellerWatchItem item) async {
    final index = _sellerItems.indexWhere(
      (sellerItem) => sellerItem.id == item.id,
    );
    if (index == -1) return;

    final previousItem = _sellerItems[index];
    _sellerItems[index] = item;
    final alertsChanged = previousItem.sellerName != item.sellerName
        ? _updateAlertSourceName(
            sourceType: 'seller',
            sourceId: item.id,
            sourceName: item.sellerName,
            previousSourceName: previousItem.sellerName,
          )
        : false;

    notifyListeners();
    await Future.wait([
      _persistSellerItems(),
      if (alertsChanged) _persistAlerts(),
    ]);
  }

  Future<void> removeWatchItem(String id) async {
    final index = _watchItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final removedItem = _watchItems.removeAt(index);
    _alerts.removeWhere(
      (alert) =>
          alert.sourceType == 'product' &&
          (alert.sourceId == id ||
              (alert.sourceId.isEmpty &&
                  alert.sourceName == removedItem.productName)),
    );
    notifyListeners();
    await Future.wait([_persistWatchItems(), _persistAlerts()]);
  }

  Future<void> removeSellerItem(String id) async {
    final index = _sellerItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final removedItem = _sellerItems.removeAt(index);
    _alerts.removeWhere(
      (alert) =>
          alert.sourceType == 'seller' &&
          (alert.sourceId == id ||
              (alert.sourceId.isEmpty &&
                  alert.sourceName == removedItem.sellerName)),
    );
    notifyListeners();
    await Future.wait([_persistSellerItems(), _persistAlerts()]);
  }

  Future<void> markAlertAsRead(String alertId) async {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1 || _alerts[index].isRead) return;

    _alerts[index] = _alerts[index].copyWith(isRead: true);
    notifyListeners();
    await _persistAlerts();
  }

  bool _updateAlertSourceName({
    required String sourceType,
    required String sourceId,
    required String sourceName,
    required String previousSourceName,
  }) {
    var changed = false;
    for (var index = 0; index < _alerts.length; index += 1) {
      final alert = _alerts[index];
      final sourceIdMatches =
          alert.sourceType == sourceType && alert.sourceId == sourceId;
      final legacyNameMatches =
          alert.sourceType == sourceType &&
          alert.sourceId.isEmpty &&
          alert.sourceName == previousSourceName;

      if ((sourceIdMatches || legacyNameMatches) &&
          (alert.sourceId != sourceId || alert.sourceName != sourceName)) {
        _alerts[index] = alert.copyWith(
          sourceId: sourceId,
          sourceName: sourceName,
        );
        changed = true;
      }
    }
    return changed;
  }

  ProductWatchItem _buildSuccessfulProductCheck({
    required ProductWatchItem currentItem,
    required ProductWatchItem trackingSnapshot,
    required ProductCheckResult result,
  }) {
    final priceChanged =
        trackingSnapshot.lastPrice > 0 &&
        trackingSnapshot.lastPrice != result.price;

    return currentItem.copyWith(
      previousPrice: trackingSnapshot.lastPrice,
      lastPrice: result.price,
      priceChanged: priceChanged,
      inStock: result.inStock,
      checkStatus: TrackingCheckStatus.success,
      lastCheckedAt: result.checkedAt,
      lastCheckError: null,
    );
  }

  _ProductCheckAlerts _buildProductCheckAlerts({
    required ProductWatchItem trackingSnapshot,
    required ProductWatchItem updatedItem,
    required DateTime checkedAt,
  }) {
    if (trackingSnapshot.lastPrice == 0) return const _ProductCheckAlerts();

    final productAlerts = <AlertEvent>[];
    final summaryAlerts = <AlertSummaryItem>[];

    void addAlert({
      required String title,
      required String message,
      required String type,
    }) {
      final alert = AlertEvent(
        title: title,
        message: message,
        createdAt: checkedAt,
        type: type,
      );
      productAlerts.add(alert);
      summaryAlerts.add(
        AlertSummaryItem(
          id: _productAlertId(
            updatedItem.id,
            type,
            checkedAt,
            productAlerts.length,
          ),
          sourceType: 'product',
          sourceId: updatedItem.id,
          sourceName: updatedItem.productName,
          title: title,
          message: message,
          createdAt: checkedAt,
          isRead: false,
        ),
      );
    }

    if (trackingSnapshot.lastPrice != updatedItem.lastPrice) {
      final priceDropped = updatedItem.lastPrice < trackingSnapshot.lastPrice;
      addAlert(
        title: priceDropped ? 'Fiyat düştü' : 'Fiyat yükseldi',
        message:
            'Fiyat ${trackingSnapshot.lastPrice} TL seviyesinden ${updatedItem.lastPrice} TL seviyesine geldi.',
        type: priceDropped ? 'price_down' : 'price_up',
      );
    }

    if (updatedItem.stockTrackingEnabled &&
        trackingSnapshot.inStock != updatedItem.inStock) {
      addAlert(
        title: updatedItem.inStock ? 'Stok geldi' : 'Stok bitti',
        message: updatedItem.inStock
            ? '${updatedItem.productName} yeniden stokta görünüyor.'
            : '${updatedItem.productName} stokta görünmüyor.',
        type: updatedItem.inStock ? 'stock_in' : 'stock_out',
      );
    }

    final targetPrice = updatedItem.targetPrice;
    if (targetPrice != null &&
        trackingSnapshot.lastPrice > targetPrice &&
        updatedItem.lastPrice <= targetPrice) {
      addAlert(
        title: 'Hedef fiyata ulaştı',
        message:
            '${updatedItem.productName} hedef fiyatınız olan $targetPrice TL seviyesine ulaştı.',
        type: 'target_price_reached',
      );
    }

    return _ProductCheckAlerts(
      productAlerts: productAlerts,
      summaryAlerts: summaryAlerts,
    );
  }

  String _productAlertId(
    String productId,
    String type,
    DateTime checkedAt,
    int sequence,
  ) {
    return 'product_alert_${productId}_${type}_${checkedAt.microsecondsSinceEpoch}_$sequence';
  }

  String _userFriendlyCheckError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'Ürün kontrolü tamamlanamadı.' : message;
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

class _ProductCheckAlerts {
  const _ProductCheckAlerts({
    this.productAlerts = const [],
    this.summaryAlerts = const [],
  });

  final List<AlertEvent> productAlerts;
  final List<AlertSummaryItem> summaryAlerts;
}
