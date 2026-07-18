import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 18, 10, 30, 45);

  test('AlertEvent supports a JSON round trip', () {
    final original = AlertEvent(
      title: 'Fiyat düştü',
      message: 'Yeni fiyat bulundu',
      createdAt: createdAt,
      type: 'price',
    );

    final restored = AlertEvent.fromJson(original.toJson());

    expect(restored.title, original.title);
    expect(restored.message, original.message);
    expect(restored.createdAt, createdAt);
    expect(restored.type, original.type);
  });

  test('ProductWatchItem preserves nested alerts and check times', () {
    final original = ProductWatchItem(
      id: 'product_test',
      productName: 'Ürün',
      productUrl: 'https://example.com/product',
      checkTimes: const ['09:00', '18:00'],
      alerts: [
        AlertEvent(
          title: 'Stok geldi',
          message: 'Ürün stokta',
          createdAt: createdAt,
          type: 'stock',
        ),
      ],
      marketplaceName: 'Pazar',
      sellerName: 'Satıcı',
      lastPrice: 1250,
      previousPrice: 1300,
      lastCheckedAt: createdAt,
      priceChanged: true,
      stockTrackingEnabled: false,
      inStock: true,
    );

    final restored = ProductWatchItem.fromJson(original.toJson());

    expect(restored.productName, original.productName);
    expect(restored.id, original.id);
    expect(restored.checkTimes, original.checkTimes);
    expect(restored.alerts, hasLength(1));
    expect(restored.alerts.first.title, 'Stok geldi');
    expect(restored.alerts.first.createdAt, createdAt);
    expect(restored.lastCheckedAt, createdAt);
    expect(restored.lastPrice, 1250);
    expect(restored.stockTrackingEnabled, isFalse);
  });

  test('SellerProductItem reads an integer JSON price as double', () {
    final restored = SellerProductItem.fromJson({
      'productName': 'Ürün',
      'productUrl': 'https://example.com/product',
      'price': 4299,
      'isNew': true,
      'detectedAt': createdAt.toIso8601String(),
    });

    expect(restored.price, 4299.0);
    expect(restored.detectedAt, createdAt);

    final roundTrip = SellerProductItem.fromJson(restored.toJson());
    expect(roundTrip.price, restored.price);
    expect(roundTrip.isNew, isTrue);
  });

  test('SellerAlertEvent supports a JSON round trip', () {
    final original = SellerAlertEvent(
      title: 'Yeni ürün',
      message: 'Ürün bulundu',
      createdAt: createdAt,
      type: 'new_product',
    );

    final restored = SellerAlertEvent.fromJson(original.toJson());

    expect(restored.title, original.title);
    expect(restored.message, original.message);
    expect(restored.createdAt, createdAt);
    expect(restored.type, original.type);
  });

  test('SellerWatchItem preserves nested products and alerts', () {
    final original = SellerWatchItem(
      id: 'seller_test',
      sellerName: 'Satıcı',
      marketplaceName: 'Pazar',
      sellerUrl: 'https://example.com/seller',
      totalProducts: 10,
      newProductsCount: 1,
      lastCheckedAt: createdAt,
      products: [
        SellerProductItem(
          productName: 'Yeni ürün',
          productUrl: 'https://example.com/new-product',
          price: 99.5,
          isNew: true,
          detectedAt: createdAt,
        ),
      ],
      alerts: [
        SellerAlertEvent(
          title: 'Ürün bulundu',
          message: 'Yeni ürün eklendi',
          createdAt: createdAt,
          type: 'new_product',
        ),
      ],
    );

    final restored = SellerWatchItem.fromJson(original.toJson());

    expect(restored.sellerName, original.sellerName);
    expect(restored.id, original.id);
    expect(restored.lastCheckedAt, createdAt);
    expect(restored.products, hasLength(1));
    expect(restored.products.first.price, 99.5);
    expect(restored.products.first.detectedAt, createdAt);
    expect(restored.alerts, hasLength(1));
    expect(restored.alerts.first.type, 'new_product');
    expect(restored.alerts.first.createdAt, createdAt);
  });

  test(
    'AlertSummaryItem supports round trip and safe source type fallback',
    () {
      final original = AlertSummaryItem(
        sourceId: 'seller_test',
        id: 'alert-1',
        sourceType: 'seller',
        sourceName: 'Satıcı',
        title: 'Başlık',
        message: 'Mesaj',
        createdAt: createdAt,
        isRead: true,
      );

      final restored = AlertSummaryItem.fromJson(original.toJson());
      final unknownSource = AlertSummaryItem.fromJson({
        ...original.toJson(),
        'sourceType': 'unknown',
      });

      expect(restored.id, original.id);
      expect(restored.sourceType, 'seller');
      expect(restored.sourceId, 'seller_test');
      expect(restored.createdAt, createdAt);
      expect(restored.isRead, isTrue);
      expect(unknownSource.sourceType, 'product');
    },
  );

  test('missing optional JSON values use safe defaults', () {
    final product = ProductWatchItem.fromJson(const {});
    final seller = SellerWatchItem.fromJson(const {});
    final alert = AlertSummaryItem.fromJson(const {});

    expect(product.checkTimes, isEmpty);
    expect(product.alerts, isEmpty);
    expect(product.stockTrackingEnabled, isTrue);
    expect(seller.products, isEmpty);
    expect(seller.alerts, isEmpty);
    expect(alert.sourceType, 'product');
    expect(alert.isRead, isFalse);
  });

  test('legacy JSON without ids gets stable fallback ids', () {
    final productJson = {
      'productName': 'Eski Ürün',
      'productUrl': 'https://example.com/legacy-product',
    };
    final sellerJson = {
      'sellerName': 'Eski Satıcı',
      'sellerUrl': 'https://example.com/legacy-seller',
    };

    final productId = ProductWatchItem.fromJson(productJson).id;
    final sellerId = SellerWatchItem.fromJson(sellerJson).id;

    expect(productId, startsWith('product_legacy_'));
    expect(sellerId, startsWith('seller_legacy_'));
    expect(ProductWatchItem.fromJson(productJson).id, productId);
    expect(SellerWatchItem.fromJson(sellerJson).id, sellerId);

    expect(
      ProductWatchItem.fromJson({
        ...productJson,
        'productName': 'Farklı Ürün',
      }).id,
      isNot(productId),
    );
    expect(
      SellerWatchItem.fromJson({
        ...sellerJson,
        'sellerName': 'Farklı Satıcı',
      }).id,
      isNot(sellerId),
    );
  });

  test(
    'null, empty, and whitespace ids use fallback while a full id is kept',
    () {
      final productJson = {
        'productName': 'Legacy Product',
        'productUrl': 'https://example.com/product',
      };
      final sellerJson = {
        'sellerName': 'Legacy Seller',
        'sellerUrl': 'https://example.com/seller',
      };
      final productFallback = ProductWatchItem.fromJson(productJson).id;
      final sellerFallback = SellerWatchItem.fromJson(sellerJson).id;

      for (final invalidId in <String?>[null, '', '   ']) {
        expect(
          ProductWatchItem.fromJson({...productJson, 'id': invalidId}).id,
          productFallback,
        );
        expect(
          SellerWatchItem.fromJson({...sellerJson, 'id': invalidId}).id,
          sellerFallback,
        );
      }

      expect(
        ProductWatchItem.fromJson({
          ...productJson,
          'id': '  product_kept  ',
        }).id,
        '  product_kept  ',
      );
      expect(
        SellerWatchItem.fromJson({...sellerJson, 'id': 'seller_kept'}).id,
        'seller_kept',
      );
    },
  );
}
