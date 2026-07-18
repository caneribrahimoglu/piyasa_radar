import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/alerts/data/repositories/fake_alerts_repository.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/features/alerts/presentation/pages/alerts_page.dart';

class _EmptyAlertsRepository extends FakeAlertsRepository {
  const _EmptyAlertsRepository();

  @override
  List<AlertSummaryItem> getAlerts() => const [];
}

void main() {
  test('combines product and seller alerts newest first', () {
    final alerts = const FakeAlertsRepository().getAlerts();

    expect(alerts, hasLength(7));
    expect(alerts.first.sourceType, 'product');
    expect(alerts.first.sourceName, 'Logitech MX Master 3S');
    expect(alerts.first.formattedCreatedAt, '17.07.2026 14:35');
    expect(alerts.any((alert) => alert.sourceType == 'seller'), isTrue);

    for (var index = 1; index < alerts.length; index++) {
      expect(
        alerts[index - 1].createdAt.isBefore(alerts[index].createdAt),
        isFalse,
      );
    }
  });

  testWidgets('shows combined alerts in the alerts tab', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.tap(find.text('Alertler'));
    await tester.pumpAndSettle();

    expect(find.text('Fiyat düştü'), findsOneWidget);
    expect(find.text('Kaynak: Logitech MX Master 3S'), findsOneWidget);
    expect(find.text('Ürün'), findsWidgets);
    expect(find.text('Satıcı'), findsWidgets);
    expect(find.text('17.07.2026 14:35'), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsNWidgets(7));

    await tester.tap(find.text('Fiyat düştü'));
    await tester.pump();

    expect(find.byIcon(Icons.circle), findsNWidgets(6));
  });

  testWidgets('shows the empty alerts state', (tester) async {
    final appState = AppState(alertsRepository: const _EmptyAlertsRepository());
    addTearDown(appState.dispose);
    await tester.pumpWidget(MaterialApp(home: AlertsPage(appState: appState)));

    expect(find.text('Henüz alert yok'), findsOneWidget);
  });
}
