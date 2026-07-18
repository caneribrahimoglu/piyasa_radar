import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';

const Object _copyWithSentinel = Object();

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
    required this.targetPrice,
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
  final int? targetPrice;
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
    'targetPrice': targetPrice,
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
      targetPrice: (json['targetPrice'] as num?)?.toInt(),
      lastCheckedAt:
          DateTime.tryParse(json['lastCheckedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      priceChanged: json['priceChanged'] as bool? ?? false,
      stockTrackingEnabled: json['stockTrackingEnabled'] as bool? ?? true,
      inStock: json['inStock'] as bool? ?? false,
    );
  }

  ProductWatchItem copyWith({
    String? id,
    String? productName,
    String? productUrl,
    List<String>? checkTimes,
    List<AlertEvent>? alerts,
    String? marketplaceName,
    String? sellerName,
    int? lastPrice,
    int? previousPrice,
    Object? targetPrice = _copyWithSentinel,
    DateTime? lastCheckedAt,
    bool? priceChanged,
    bool? stockTrackingEnabled,
    bool? inStock,
  }) {
    return ProductWatchItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productUrl: productUrl ?? this.productUrl,
      checkTimes: checkTimes ?? this.checkTimes,
      alerts: alerts ?? this.alerts,
      marketplaceName: marketplaceName ?? this.marketplaceName,
      sellerName: sellerName ?? this.sellerName,
      lastPrice: lastPrice ?? this.lastPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      targetPrice: identical(targetPrice, _copyWithSentinel)
          ? this.targetPrice
          : targetPrice as int?,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      priceChanged: priceChanged ?? this.priceChanged,
      stockTrackingEnabled: stockTrackingEnabled ?? this.stockTrackingEnabled,
      inStock: inStock ?? this.inStock,
    );
  }

  bool get priceIncreased => lastPrice > previousPrice;

  bool get priceDecreased => lastPrice < previousPrice;

  String get formattedLastPrice =>
      lastPrice == 0 ? 'Henüz kontrol edilmedi' : '$lastPrice TL';

  String get formattedPreviousPrice =>
      previousPrice == 0 ? 'Veri yok' : '$previousPrice TL';

  String get formattedTargetPrice =>
      targetPrice == null ? 'Belirlenmedi' : '$targetPrice TL';

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
