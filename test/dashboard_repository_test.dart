import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/dashboard/data/repositories/fake_dashboard_repository.dart';
import 'package:piyasa_radar/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:piyasa_radar/features/watchlist/data/repositories/fake_watchlist_repository.dart';
import 'package:piyasa_radar/shared/widgets/app_card.dart';

void main() {
  test('calculates dashboard values from the provided state lists', () {
    final appState = AppState();
    addTearDown(appState.dispose);

    final summary = const FakeDashboardRepository().getSummary(
      watchItems: appState.watchItems,
      sellerItems: appState.sellerItems,
      alerts: appState.alerts,
    );

    expect(summary.trackedProductCount, 3);
    expect(summary.trackedSellerCount, 3);
    expect(summary.activeAlertCount, 7);
    expect(summary.newProductCount, 4);
  });

  testWidgets('shows values calculated from app state', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DashboardPage(appState: appState)),
      ),
    );

    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('updates dashboard immediately when app state changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DashboardPage(appState: appState)),
      ),
    );

    final productCard = find.ancestor(
      of: find.text('Takip edilen ürün'),
      matching: find.byType(AppCard),
    );
    final alertCard = find.ancestor(
      of: find.text('Aktif alert'),
      matching: find.byType(AppCard),
    );
    expect(
      find.descendant(of: productCard, matching: find.text('3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: alertCard, matching: find.text('7')),
      findsOneWidget,
    );

    appState.addWatchItem(
      const FakeWatchlistRepository().getWatchItems().first,
    );
    appState.markAlertAsRead(appState.alerts.first.id);
    await tester.pump();

    expect(
      find.descendant(of: productCard, matching: find.text('4')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: alertCard, matching: find.text('6')),
      findsOneWidget,
    );
  });
}
