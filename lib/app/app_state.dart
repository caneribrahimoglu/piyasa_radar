import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:piyasa_radar/features/alerts/data/repositories/fake_alerts_repository.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

class AppState extends ChangeNotifier {
  AppState({
    FakeWatchlistRepository watchlistRepository =
        const FakeWatchlistRepository(),
    FakeSellerTrackingRepository sellerTrackingRepository =
        const FakeSellerTrackingRepository(),
    FakeAlertsRepository? alertsRepository,
  }) {
    _watchItems = List<ProductWatchItem>.of(
      watchlistRepository.getWatchItems(),
    );
    _sellerItems = List<SellerWatchItem>.of(
      sellerTrackingRepository.getSellerWatchItems(),
    );
    _alerts = List<AlertSummaryItem>.of(
      (alertsRepository ??
              FakeAlertsRepository(
                watchlistRepository: watchlistRepository,
                sellerTrackingRepository: sellerTrackingRepository,
              ))
          .getAlerts(),
    );
  }

  late final List<ProductWatchItem> _watchItems;
  late final List<SellerWatchItem> _sellerItems;
  late final List<AlertSummaryItem> _alerts;

  UnmodifiableListView<ProductWatchItem> get watchItems =>
      UnmodifiableListView(_watchItems);
  UnmodifiableListView<SellerWatchItem> get sellerItems =>
      UnmodifiableListView(_sellerItems);
  UnmodifiableListView<AlertSummaryItem> get alerts =>
      UnmodifiableListView(_alerts);

  void addWatchItem(ProductWatchItem item) {
    _watchItems.add(item);
    notifyListeners();
  }

  void addSellerItem(SellerWatchItem item) {
    _sellerItems.add(item);
    notifyListeners();
  }

  void markAlertAsRead(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1 || _alerts[index].isRead) {
      return;
    }

    _alerts[index] = _alerts[index].copyWith(isRead: true);
    notifyListeners();
  }
}
