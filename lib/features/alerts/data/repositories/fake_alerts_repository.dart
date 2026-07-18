import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/seller_tracking/data/repositories/fake_seller_tracking_repository.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';

class FakeAlertsRepository {
  const FakeAlertsRepository({
    this.watchlistRepository = const FakeWatchlistRepository(),
    this.sellerTrackingRepository = const FakeSellerTrackingRepository(),
  });

  final FakeWatchlistRepository watchlistRepository;
  final FakeSellerTrackingRepository sellerTrackingRepository;

  List<AlertSummaryItem> getAlerts() {
    final alerts = <AlertSummaryItem>[];

    final products = watchlistRepository.getWatchItems();
    for (var productIndex = 0; productIndex < products.length; productIndex++) {
      final product = products[productIndex];
      for (
        var alertIndex = 0;
        alertIndex < product.alerts.length;
        alertIndex++
      ) {
        final alert = product.alerts[alertIndex];
        alerts.add(
          AlertSummaryItem(
            id: 'product-$productIndex-$alertIndex',
            sourceType: 'product',
            sourceName: product.productName,
            title: alert.title,
            message: alert.message,
            createdAt: alert.createdAt,
            isRead: false,
          ),
        );
      }
    }

    final sellers = sellerTrackingRepository.getSellerWatchItems();
    for (var sellerIndex = 0; sellerIndex < sellers.length; sellerIndex++) {
      final seller = sellers[sellerIndex];
      for (
        var alertIndex = 0;
        alertIndex < seller.alerts.length;
        alertIndex++
      ) {
        final alert = seller.alerts[alertIndex];
        alerts.add(
          AlertSummaryItem(
            id: 'seller-$sellerIndex-$alertIndex',
            sourceType: 'seller',
            sourceName: seller.sellerName,
            title: alert.title,
            message: alert.message,
            createdAt: alert.createdAt,
            isRead: false,
          ),
        );
      }
    }

    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alerts;
  }
}
