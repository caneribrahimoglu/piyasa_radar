import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';

void main() {
  test('adding a product increases the AppState product count', () {
    final appState = AppState();
    addTearDown(appState.dispose);
    final initialCount = appState.watchItems.length;

    appState.addWatchItem(
      const FakeWatchlistRepository().getWatchItems().first,
    );

    expect(appState.watchItems, hasLength(initialCount + 1));
  });

  test('adding a seller increases the AppState seller count', () {
    final appState = AppState();
    addTearDown(appState.dispose);
    final initialCount = appState.sellerItems.length;

    appState.addSellerItem(
      SellerWatchItem(
        sellerName: 'Yeni Satıcı',
        marketplaceName: 'Pazar',
        sellerUrl: 'https://example.com',
        totalProducts: 0,
        newProductsCount: 0,
        lastCheckedAt: DateTime(2026),
        products: const [],
        alerts: const [],
      ),
    );

    expect(appState.sellerItems, hasLength(initialCount + 1));
  });

  test('marking an alert as read decreases the unread count', () {
    final appState = AppState();
    addTearDown(appState.dispose);
    final alert = appState.alerts.first;
    final initialUnread = appState.alerts.where((item) => !item.isRead).length;

    appState.markAlertAsRead(alert.id);
    appState.markAlertAsRead(alert.id);

    expect(
      appState.alerts.where((item) => !item.isRead),
      hasLength(initialUnread - 1),
    );
    expect(appState.alerts.first.isRead, isTrue);
  });

  test('exposed state lists cannot be modified', () {
    final appState = AppState();
    addTearDown(appState.dispose);

    expect(
      () => appState.watchItems.add(appState.watchItems.first),
      throwsUnsupportedError,
    );
  });
}
