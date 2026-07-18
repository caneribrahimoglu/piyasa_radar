class SellerProductItem {
  const SellerProductItem({
    required this.productName,
    required this.productUrl,
    required this.price,
    required this.isNew,
    required this.detectedAt,
  });

  final String productName;
  final String productUrl;
  final double price;
  final bool isNew;
  final DateTime detectedAt;

  String get formattedPrice {
    final value = price == price.truncateToDouble()
        ? price.toInt().toString()
        : price.toString();
    return '$value TL';
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'productUrl': productUrl,
    'price': price,
    'isNew': isNew,
    'detectedAt': detectedAt.toIso8601String(),
  };

  factory SellerProductItem.fromJson(Map<String, dynamic> json) {
    return SellerProductItem(
      productName: json['productName'] as String? ?? '',
      productUrl: json['productUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isNew: json['isNew'] as bool? ?? false,
      detectedAt:
          DateTime.tryParse(json['detectedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String get formattedDetectedAt {
    final day = _twoDigits(detectedAt.day);
    final month = _twoDigits(detectedAt.month);
    final year = detectedAt.year;
    final hour = _twoDigits(detectedAt.hour);
    final minute = _twoDigits(detectedAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
