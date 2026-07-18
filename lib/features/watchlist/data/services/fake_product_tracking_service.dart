import 'package:piyasa_radar/features/watchlist/domain/models/product_check_result.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/domain/services/product_tracking_service.dart';

class FakeProductTrackingService implements ProductTrackingService {
  const FakeProductTrackingService({
    this.delay = const Duration(milliseconds: 350),
  });

  final Duration delay;

  @override
  Future<ProductCheckResult> checkProduct(ProductWatchItem item) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (item.productUrl.toLowerCase().contains('error')) {
      throw Exception('Ürün bilgisi şu anda okunamadı.');
    }

    final price = item.lastPrice == 0 ? _initialPrice(item) : _nextPrice(item);

    return ProductCheckResult(
      price: price,
      inStock: _nextStockState(item),
      checkedAt: DateTime.now(),
    );
  }

  int _initialPrice(ProductWatchItem item) {
    return 1000 + (_hash('${item.productName}|${item.productUrl}') % 7000);
  }

  int _nextPrice(ProductWatchItem item) {
    final direction = _hash(item.id).isEven ? -1 : 1;
    final amount = 75 + (_hash('${item.id}|${item.lastPrice}') % 225);
    final nextPrice = item.lastPrice + (direction * amount);
    return nextPrice < 1 ? 1 : nextPrice;
  }

  bool _nextStockState(ProductWatchItem item) {
    final hash = _hash('${item.id}|${item.lastPrice}|stock');
    if (hash % 5 == 0) return !item.inStock;
    return item.inStock;
  }

  int _hash(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
