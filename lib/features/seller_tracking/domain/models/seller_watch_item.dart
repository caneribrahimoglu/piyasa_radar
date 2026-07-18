import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';

class SellerWatchItem {
  const SellerWatchItem({
    required this.sellerName,
    required this.marketplaceName,
    required this.sellerUrl,
    required this.totalProducts,
    required this.newProductsCount,
    required this.lastCheckedAt,
    required this.products,
    required this.alerts,
  });

  final String sellerName;
  final String marketplaceName;
  final String sellerUrl;
  final int totalProducts;
  final int newProductsCount;
  final DateTime lastCheckedAt;
  final List<SellerProductItem> products;
  final List<SellerAlertEvent> alerts;

  String get formattedLastCheckedAt {
    final day = _twoDigits(lastCheckedAt.day);
    final month = _twoDigits(lastCheckedAt.month);
    final year = lastCheckedAt.year;
    final hour = _twoDigits(lastCheckedAt.hour);
    final minute = _twoDigits(lastCheckedAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
