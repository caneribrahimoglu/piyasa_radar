import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';

class SellerWatchItem {
  const SellerWatchItem({
    required this.id,
    required this.sellerName,
    required this.marketplaceName,
    required this.sellerUrl,
    required this.totalProducts,
    required this.newProductsCount,
    required this.lastCheckedAt,
    required this.products,
    required this.alerts,
  });

  final String id;
  final String sellerName;
  final String marketplaceName;
  final String sellerUrl;
  final int totalProducts;
  final int newProductsCount;
  final DateTime lastCheckedAt;
  final List<SellerProductItem> products;
  final List<SellerAlertEvent> alerts;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerName': sellerName,
    'marketplaceName': marketplaceName,
    'sellerUrl': sellerUrl,
    'totalProducts': totalProducts,
    'newProductsCount': newProductsCount,
    'lastCheckedAt': lastCheckedAt.toIso8601String(),
    'products': products.map((product) => product.toJson()).toList(),
    'alerts': alerts.map((alert) => alert.toJson()).toList(),
  };

  factory SellerWatchItem.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'];
    final alertsJson = json['alerts'];

    return SellerWatchItem(
      id:
          json['id'] as String? ??
          _legacyId(
            json['sellerName'] as String? ?? '',
            json['sellerUrl'] as String? ?? '',
          ),
      sellerName: json['sellerName'] as String? ?? '',
      marketplaceName: json['marketplaceName'] as String? ?? '',
      sellerUrl: json['sellerUrl'] as String? ?? '',
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      newProductsCount: (json['newProductsCount'] as num?)?.toInt() ?? 0,
      lastCheckedAt:
          DateTime.tryParse(json['lastCheckedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      products: productsJson is List
          ? productsJson
                .whereType<Map>()
                .map(
                  (product) => SellerProductItem.fromJson(
                    Map<String, dynamic>.from(product),
                  ),
                )
                .toList()
          : const [],
      alerts: alertsJson is List
          ? alertsJson
                .whereType<Map>()
                .map(
                  (alert) => SellerAlertEvent.fromJson(
                    Map<String, dynamic>.from(alert),
                  ),
                )
                .toList()
          : const [],
    );
  }

  String get formattedLastCheckedAt {
    final day = _twoDigits(lastCheckedAt.day);
    final month = _twoDigits(lastCheckedAt.month);
    final year = lastCheckedAt.year;
    final hour = _twoDigits(lastCheckedAt.hour);
    final minute = _twoDigits(lastCheckedAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _legacyId(String name, String url) {
    var hash = 2166136261;
    for (final codeUnit in '$name|$url'.codeUnits) {
      hash = ((hash ^ codeUnit) * 16777619) & 0xFFFFFFFF;
    }
    return 'seller_legacy_${hash.toRadixString(16)}';
  }
}
