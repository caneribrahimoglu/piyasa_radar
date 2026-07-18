class DashboardSummary {
  const DashboardSummary({
    required this.trackedProductCount,
    required this.trackedSellerCount,
    required this.activeAlertCount,
    required this.newProductCount,
  });

  final int trackedProductCount;
  final int trackedSellerCount;
  final int activeAlertCount;
  final int newProductCount;
}
