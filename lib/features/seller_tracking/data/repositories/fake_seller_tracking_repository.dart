import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';

class FakeSellerTrackingRepository {
  const FakeSellerTrackingRepository();

  List<SellerWatchItem> getSellerWatchItems() {
    return [
      SellerWatchItem(
        id: 'seller_teknolojiplus',
        sellerName: 'TeknolojiPlus',
        marketplaceName: 'Trendyol',
        sellerUrl: 'https://www.trendyol.com/magaza/teknolojiplus',
        checkTimes: defaultCheckTimes,
        totalProducts: 128,
        newProductsCount: 6,
        checkStatus: TrackingCheckStatus.success,
        lastCheckedAt: DateTime(2026, 7, 17, 14, 20),
        lastCheckError: null,
        products: [
          SellerProductItem(
            productName: 'Logitech MX Keys S',
            productUrl: 'https://www.trendyol.com/logitech-mx-keys-s',
            price: 4299,
            isNew: true,
            detectedAt: DateTime(2026, 7, 17, 14, 18),
          ),
          SellerProductItem(
            productName: 'Logitech Lift Mouse',
            productUrl: 'https://www.trendyol.com/logitech-lift-mouse',
            price: 1899,
            isNew: false,
            detectedAt: DateTime(2026, 7, 16, 10, 05),
          ),
        ],
        alerts: [
          SellerAlertEvent(
            title: 'Yeni ürün tespit edildi',
            message: 'Logitech MX Keys S satıcı listesine eklendi.',
            createdAt: DateTime(2026, 7, 17, 14, 18),
            type: 'new_product',
          ),
          SellerAlertEvent(
            title: 'Ürün fiyatı değişti',
            message:
                'Logitech Lift Mouse fiyatı 1999 TL seviyesinden 1899 TL seviyesine indi.',
            createdAt: DateTime(2026, 7, 16, 10, 05),
            type: 'price_change',
          ),
        ],
      ),
      SellerWatchItem(
        id: 'seller_depomarket',
        sellerName: 'DepoMarket',
        marketplaceName: 'Hepsiburada',
        sellerUrl: 'https://www.hepsiburada.com/magaza/depomarket',
        checkTimes: defaultCheckTimes,
        totalProducts: 84,
        newProductsCount: 2,
        checkStatus: TrackingCheckStatus.failed,
        lastCheckedAt: DateTime(2026, 7, 17, 13, 45),
        lastCheckError: 'Satıcı ürün listesi geçici olarak okunamadı.',
        products: [
          SellerProductItem(
            productName: 'Kingston NV3 1TB',
            productUrl: 'https://www.hepsiburada.com/kingston-nv3-1tb',
            price: 2399,
            isNew: true,
            detectedAt: DateTime(2026, 7, 17, 13, 40),
          ),
          SellerProductItem(
            productName: 'Samsung 990 Evo 2TB',
            productUrl: 'https://www.hepsiburada.com/samsung-990-evo-2tb',
            price: 4999,
            isNew: false,
            detectedAt: DateTime(2026, 7, 15, 16, 20),
          ),
        ],
        alerts: [
          SellerAlertEvent(
            title: 'Ürün listeden kalktı',
            message: 'WD Blue SN580 1TB artık satıcı listesinde görünmüyor.',
            createdAt: DateTime(2026, 7, 17, 13, 35),
            type: 'product_removed',
          ),
        ],
      ),
      SellerWatchItem(
        id: 'seller_cepdukkani',
        sellerName: 'CepDükkanı',
        marketplaceName: 'N11',
        sellerUrl: 'https://www.n11.com/magaza/cepdukkani',
        checkTimes: defaultCheckTimes,
        totalProducts: 46,
        newProductsCount: 4,
        checkStatus: TrackingCheckStatus.neverChecked,
        lastCheckedAt: null,
        lastCheckError: null,
        products: [
          SellerProductItem(
            productName: 'iPhone 15 Silikon Kılıf',
            productUrl: 'https://www.n11.com/iphone-15-silikon-kilif',
            price: 499,
            isNew: true,
            detectedAt: DateTime(2026, 7, 16, 21, 25),
          ),
          SellerProductItem(
            productName: 'USB-C 20W Şarj Adaptörü',
            productUrl: 'https://www.n11.com/usb-c-20w-sarj-adaptoru',
            price: 699,
            isNew: true,
            detectedAt: DateTime(2026, 7, 16, 21, 10),
          ),
        ],
        alerts: [
          SellerAlertEvent(
            title: 'Yeni ürün tespit edildi',
            message: 'USB-C 20W Şarj Adaptörü satıcı listesine eklendi.',
            createdAt: DateTime(2026, 7, 16, 21, 10),
            type: 'new_product',
          ),
        ],
      ),
    ];
  }
}
