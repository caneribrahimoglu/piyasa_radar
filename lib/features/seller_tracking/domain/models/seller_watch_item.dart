import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';

const Object _copyWithSentinel = Object();

class SellerWatchItem {
  const SellerWatchItem({
    required this.id,
    required this.sellerName,
    required this.marketplaceName,
    required this.sellerUrl,
    required this.checkTimes,
    required this.totalProducts,
    required this.newProductsCount,
    required this.checkStatus,
    required this.lastCheckedAt,
    required this.lastCheckError,
    required this.products,
    required this.alerts,
  });

  final String id;
  final String sellerName;
  final String marketplaceName;
  final String sellerUrl;
  final List<String> checkTimes;
  final int totalProducts;
  final int newProductsCount;
  final TrackingCheckStatus checkStatus;
  final DateTime? lastCheckedAt;
  final String? lastCheckError;
  final List<SellerProductItem> products;
  final List<SellerAlertEvent> alerts;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerName': sellerName,
    'marketplaceName': marketplaceName,
    'sellerUrl': sellerUrl,
    'checkTimes': checkTimes,
    'totalProducts': totalProducts,
    'newProductsCount': newProductsCount,
    'checkStatus': trackingCheckStatusToJson(checkStatus),
    'lastCheckedAt': lastCheckedAt?.toIso8601String(),
    'lastCheckError': lastCheckError,
    'products': products.map((product) => product.toJson()).toList(),
    'alerts': alerts.map((alert) => alert.toJson()).toList(),
  };

  factory SellerWatchItem.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'];
    final alertsJson = json['alerts'];
    final checkTimesJson = json['checkTimes'];
    final id = json['id'] as String?;
    final parsedLastCheckedAt = DateTime.tryParse(
      json['lastCheckedAt'] as String? ?? '',
    );
    final rawCheckStatus = json['checkStatus'];

    return SellerWatchItem(
      id: id == null || id.trim().isEmpty
          ? _legacyId(
              json['sellerName'] as String? ?? '',
              json['sellerUrl'] as String? ?? '',
            )
          : id,
      sellerName: json['sellerName'] as String? ?? '',
      marketplaceName: json['marketplaceName'] as String? ?? '',
      sellerUrl: json['sellerUrl'] as String? ?? '',
      checkTimes: checkTimesJson is List
          ? normalizeCheckTimes(
              checkTimesJson.whereType<String>(),
              fallback: defaultCheckTimes,
            )
          : defaultCheckTimes,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      newProductsCount: (json['newProductsCount'] as num?)?.toInt() ?? 0,
      checkStatus: rawCheckStatus == null
          ? parsedLastCheckedAt == null
                ? TrackingCheckStatus.neverChecked
                : TrackingCheckStatus.success
          : trackingCheckStatusFromJson(rawCheckStatus),
      lastCheckedAt: parsedLastCheckedAt,
      lastCheckError: json['lastCheckError'] as String?,
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

  SellerWatchItem copyWith({
    String? id,
    String? sellerName,
    String? marketplaceName,
    String? sellerUrl,
    List<String>? checkTimes,
    int? totalProducts,
    int? newProductsCount,
    TrackingCheckStatus? checkStatus,
    Object? lastCheckedAt = _copyWithSentinel,
    Object? lastCheckError = _copyWithSentinel,
    List<SellerProductItem>? products,
    List<SellerAlertEvent>? alerts,
  }) {
    return SellerWatchItem(
      id: id ?? this.id,
      sellerName: sellerName ?? this.sellerName,
      marketplaceName: marketplaceName ?? this.marketplaceName,
      sellerUrl: sellerUrl ?? this.sellerUrl,
      checkTimes: checkTimes == null
          ? this.checkTimes
          : normalizeCheckTimes(checkTimes, fallback: defaultCheckTimes),
      totalProducts: totalProducts ?? this.totalProducts,
      newProductsCount: newProductsCount ?? this.newProductsCount,
      checkStatus: checkStatus ?? this.checkStatus,
      lastCheckedAt: identical(lastCheckedAt, _copyWithSentinel)
          ? this.lastCheckedAt
          : lastCheckedAt as DateTime?,
      lastCheckError: identical(lastCheckError, _copyWithSentinel)
          ? this.lastCheckError
          : lastCheckError as String?,
      products: products ?? this.products,
      alerts: alerts ?? this.alerts,
    );
  }

  String get formattedCheckTimes => checkTimes.join(', ');

  String get formattedLastCheckedAt {
    final lastCheckedAt = this.lastCheckedAt;
    if (lastCheckedAt == null) return 'Henüz kontrol edilmedi';

    final day = _twoDigits(lastCheckedAt.day);
    final month = _twoDigits(lastCheckedAt.month);
    final year = lastCheckedAt.year;
    final hour = _twoDigits(lastCheckedAt.hour);
    final minute = _twoDigits(lastCheckedAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  String get checkStatusLabel => checkStatus.label;

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _legacyId(String name, String url) {
    var hash = 17;
    for (final codeUnit in '$name|$url'.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return 'seller_legacy_${hash.toRadixString(16)}';
  }
}
