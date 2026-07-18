import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';

class ProductWatchItem {
  const ProductWatchItem({
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
    required this.inStock,
  });

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
  final bool inStock;

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
}
