import 'package:piyasa_radar/core/storage/app_storage.dart';

class MemoryAppStorage implements AppStorage {
  String? watchItems;
  String? sellerItems;
  String? alerts;
  String? themeMode;

  @override
  Future<String?> readWatchItems() async => watchItems;

  @override
  Future<void> writeWatchItems(String value) async => watchItems = value;

  @override
  Future<String?> readSellerItems() async => sellerItems;

  @override
  Future<void> writeSellerItems(String value) async => sellerItems = value;

  @override
  Future<String?> readAlerts() async => alerts;

  @override
  Future<void> writeAlerts(String value) async => alerts = value;

  @override
  Future<String?> readThemeMode() async => themeMode;

  @override
  Future<void> writeThemeMode(String value) async => themeMode = value;
}
