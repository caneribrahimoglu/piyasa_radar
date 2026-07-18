import 'package:piyasa_radar/core/storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAppStorage implements AppStorage {
  SharedPreferencesAppStorage()
    : _preferences = SharedPreferences.getInstance();

  static const _watchItemsKey = 'watch_items';
  static const _sellerItemsKey = 'seller_items';
  static const _alertsKey = 'alerts';
  static const _themeModeKey = 'theme_mode';

  final Future<SharedPreferences> _preferences;

  @override
  Future<String?> readWatchItems() async =>
      (await _preferences).getString(_watchItemsKey);

  @override
  Future<void> writeWatchItems(String value) async {
    await (await _preferences).setString(_watchItemsKey, value);
  }

  @override
  Future<String?> readSellerItems() async =>
      (await _preferences).getString(_sellerItemsKey);

  @override
  Future<void> writeSellerItems(String value) async {
    await (await _preferences).setString(_sellerItemsKey, value);
  }

  @override
  Future<String?> readAlerts() async =>
      (await _preferences).getString(_alertsKey);

  @override
  Future<void> writeAlerts(String value) async {
    await (await _preferences).setString(_alertsKey, value);
  }

  @override
  Future<String?> readThemeMode() async =>
      (await _preferences).getString(_themeModeKey);

  @override
  Future<void> writeThemeMode(String value) async {
    await (await _preferences).setString(_themeModeKey, value);
  }
}
