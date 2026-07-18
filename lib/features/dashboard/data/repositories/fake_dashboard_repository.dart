import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

class FakeDashboardRepository {
  const FakeDashboardRepository();

  DashboardSummary getSummary({
    required List<ProductWatchItem> watchItems,
    required List<SellerWatchItem> sellerItems,
    required List<AlertSummaryItem> alerts,
  }) {
    final newProductCount = sellerItems.fold<int>(
      0,
      (total, seller) =>
          total + seller.products.where((product) => product.isNew).length,
    );

    return DashboardSummary(
      trackedProductCount: watchItems.length,
      trackedSellerCount: sellerItems.length,
      activeAlertCount: alerts.where((alert) => !alert.isRead).length,
      newProductCount: newProductCount,
    );
  }
}
