import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

class FakeWatchlistRepository {
  const FakeWatchlistRepository();

  List<ProductWatchItem> getWatchItems() {
    return [
      ProductWatchItem(
        id: 'product_logitech_mx_master_3s',
        productName: 'Logitech MX Master 3S',
        productUrl: 'https://www.trendyol.com/logitech-mx-master-3s',
        checkTimes: defaultCheckTimes,
        alerts: [
          AlertEvent(
            title: 'Fiyat düştü',
            message:
                'Ürün fiyatı 3499 TL seviyesinden 3299 TL seviyesine indi.',
            createdAt: DateTime(2026, 7, 17, 14, 35),
            type: 'price',
          ),
        ],
        marketplaceName: 'Trendyol',
        sellerName: 'TeknolojiPlus',
        lastPrice: 3299,
        previousPrice: 3499,
        targetPrice: 3000,
        checkStatus: TrackingCheckStatus.success,
        lastCheckedAt: DateTime(2026, 7, 17, 14, 30),
        lastCheckError: null,
        priceChanged: true,
        stockTrackingEnabled: true,
        inStock: true,
      ),
      ProductWatchItem(
        id: 'product_samsung_980_pro_1tb',
        productName: 'Samsung 980 Pro 1TB',
        productUrl: 'https://www.hepsiburada.com/samsung-980-pro-1tb',
        checkTimes: defaultCheckTimes,
        alerts: [
          AlertEvent(
            title: 'Stok bitti',
            message: 'DepoMarket satıcısında ürün stok dışı oldu.',
            createdAt: DateTime(2026, 7, 17, 13, 15),
            type: 'stock',
          ),
        ],
        marketplaceName: 'Hepsiburada',
        sellerName: 'DepoMarket',
        lastPrice: 2899,
        previousPrice: 2799,
        targetPrice: 2600,
        checkStatus: TrackingCheckStatus.failed,
        lastCheckedAt: DateTime(2026, 7, 17, 13, 10),
        lastCheckError: 'Pazaryeri stok bilgisi okunamadı.',
        priceChanged: true,
        stockTrackingEnabled: true,
        inStock: false,
      ),
      ProductWatchItem(
        id: 'product_iphone_15_128gb',
        productName: 'iPhone 15 128GB',
        productUrl: 'https://www.n11.com/iphone-15-128gb',
        checkTimes: defaultCheckTimes,
        alerts: [
          AlertEvent(
            title: 'Stok geldi',
            message: 'CepDükkanı satıcısında ürün tekrar stokta.',
            createdAt: DateTime(2026, 7, 16, 22, 00),
            type: 'stock',
          ),
        ],
        marketplaceName: 'N11',
        sellerName: 'CepDükkanı',
        lastPrice: 48999,
        previousPrice: 48999,
        targetPrice: null,
        checkStatus: TrackingCheckStatus.neverChecked,
        lastCheckedAt: null,
        lastCheckError: null,
        priceChanged: false,
        stockTrackingEnabled: false,
        inStock: true,
      ),
    ];
  }
}
