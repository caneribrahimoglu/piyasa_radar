import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/alerts/presentation/pages/alerts_page.dart';
import 'package:piyasa_radar/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/pages/seller_tracking_page.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/watchlist_home_page.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({
    required this.appState,
    required this.onToggleTheme,
    super.key,
  });

  final AppState appState;
  final ValueChanged<Brightness> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Piyasa Radar'),
          actions: [
            Builder(
              builder: (context) {
                final brightness = Theme.of(context).brightness;
                final isDark = brightness == Brightness.dark;

                return IconButton(
                  key: const Key('theme-toggle-button'),
                  tooltip: isDark ? 'Açık temaya geç' : 'Koyu temaya geç',
                  onPressed: () => onToggleTheme(brightness),
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Özet'),
              Tab(text: 'Ürün Takibi'),
              Tab(text: 'Satıcı Takibi'),
              Tab(text: 'Alertler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardPage(appState: appState),
            WatchlistHomePage(appState: appState, showAppBar: false),
            SellerTrackingPage(appState: appState),
            AlertsPage(appState: appState),
          ],
        ),
      ),
    );
  }
}
