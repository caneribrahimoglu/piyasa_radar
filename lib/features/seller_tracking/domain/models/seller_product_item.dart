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
  final int price;
  final bool isNew;
  final DateTime detectedAt;

  String get formattedPrice => '$price TL';

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
