import 'package:piyasa_radar/features/watchlist/domain/models/product_check_result.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

abstract class ProductTrackingService {
  Future<ProductCheckResult> checkProduct(ProductWatchItem item);
}
