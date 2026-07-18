class ProductCheckResult {
  const ProductCheckResult({
    required this.price,
    required this.inStock,
    required this.checkedAt,
  });

  final int price;
  final bool inStock;
  final DateTime checkedAt;
}
