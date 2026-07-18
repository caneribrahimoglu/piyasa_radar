import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';

class ProductWatchItem {
  const ProductWatchItem({
    required this.id,
    required this.productName,
    required this.productUrl,
    required this.checkTimes,
    required this.alerts,
    required this.marketplaceName,
    required this.sellerName,
    required this.lastPrice,
    required this.previousPrice,
    required this.lastCheckedAt,
    required this.priceChanged,
    required this.stockTrackingEnabled,
    required this.inStock,
  });

  final String id;
  final String productName;
  final String productUrl;
  final List<String> checkTimes;
  final List<AlertEvent> alerts;
  final String marketplaceName;
  final String sellerName;
  final int lastPrice;
  final int previousPrice;
  final DateTime lastCheckedAt;
  final bool priceChanged;
  final bool stockTrackingEnabled;
  final bool inStock;

  Map<String, dynamic> toJson() => {
    'id': id,
    'productName': productName,
    'productUrl': productUrl,
    'checkTimes': checkTimes,
    'alerts': alerts.map((alert) => alert.toJson()).toList(),
    'marketplaceName': marketplaceName,
    'sellerName': sellerName,
    'lastPrice': lastPrice,
    'previousPrice': previousPrice,
    'lastCheckedAt': lastCheckedAt.toIso8601String(),
    'priceChanged': priceChanged,
    'stockTrackingEnabled': stockTrackingEnabled,
    'inStock': inStock,
  };

  factory ProductWatchItem.fromJson(Map<String, dynamic> json) {
    final checkTimesJson = json['checkTimes'];
    final alertsJson = json['alerts'];
    final id = json['id'] as String?;

    return ProductWatchItem(
      id: id == null || id.trim().isEmpty
          ? _legacyId(
              json['productName'] as String? ?? '',
              json['productUrl'] as String? ?? '',
            )
          : id,
      productName: json['productName'] as String? ?? '',
      productUrl: json['productUrl'] as String? ?? '',
      checkTimes: checkTimesJson is List
          ? checkTimesJson.whereType<String>().toList()
          : const [],
      alerts: alertsJson is List
          ? alertsJson
                .whereType<Map>()
                .map(
                  (alert) =>
                      AlertEvent.fromJson(Map<String, dynamic>.from(alert)),
                )
                .toList()
          : const [],
      marketplaceName: json['marketplaceName'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      lastPrice: (json['lastPrice'] as num?)?.toInt() ?? 0,
      previousPrice: (json['previousPrice'] as num?)?.toInt() ?? 0,
      lastCheckedAt:
          DateTime.tryParse(json['lastCheckedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      priceChanged: json['priceChanged'] as bool? ?? false,
      stockTrackingEnabled: json['stockTrackingEnabled'] as bool? ?? true,
      inStock: json['inStock'] as bool? ?? false,
    );
  }

  bool get priceIncreased => lastPrice > previousPrice;

  bool get priceDecreased => lastPrice < previousPrice;

  String get formattedLastPrice => '$lastPrice TL';

  String get formattedPreviousPrice => '$previousPrice TL';

  String get formattedLastCheckedAt {
    final day = _twoDigits(lastCheckedAt.day);
    final month = _twoDigits(lastCheckedAt.month);
    final year = lastCheckedAt.year;
    final hour = _twoDigits(lastCheckedAt.hour);
    final minute = _twoDigits(lastCheckedAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  String get formattedCheckTimes => checkTimes.join(', ');

  String get stockLabel => inStock ? 'Stokta' : 'Stokta yok';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _legacyId(String name, String url) {
    var hash = 17;
    for (final codeUnit in '$name|$url'.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return 'product_legacy_${hash.toRadixString(16)}';
  }
}
