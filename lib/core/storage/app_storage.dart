abstract class AppStorage {
  Future<String?> readWatchItems();
  Future<void> writeWatchItems(String value);

  Future<String?> readSellerItems();
  Future<void> writeSellerItems(String value);

  Future<String?> readAlerts();
  Future<void> writeAlerts(String value);

  Future<String?> readThemeMode();
  Future<void> writeThemeMode(String value);
}
