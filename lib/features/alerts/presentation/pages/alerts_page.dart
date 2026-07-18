import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/features/alerts/presentation/widgets/alert_summary_card.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final alerts = appState.alerts;
        return PageContainer(
          maxWidth: 1100,
          child: alerts.isEmpty
              ? const Center(child: Text('Henüz alert yok'))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  itemCount: alerts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => AlertSummaryCard(
                    item: alerts[index],
                    onTap: () => appState.markAlertAsRead(alerts[index].id),
                  ),
                ),
        );
      },
    );
  }
}
