import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/features/dashboard/data/repositories/fake_dashboard_repository.dart';
import 'package:piyasa_radar/features/dashboard/presentation/widgets/dashboard_summary_card.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.appState,
    this.repository = const FakeDashboardRepository(),
    super.key,
  });

  final AppState appState;
  final FakeDashboardRepository repository;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final summary = repository.getSummary(
          watchItems: appState.watchItems,
          sellerItems: appState.sellerItems,
          alerts: appState.alerts,
        );
        final summaryItems = [
          _DashboardSummaryItem(
            title: 'Takip edilen ürün',
            value: summary.trackedProductCount.toString(),
          ),
          _DashboardSummaryItem(
            title: 'Takip edilen satıcı',
            value: summary.trackedSellerCount.toString(),
          ),
          _DashboardSummaryItem(
            title: 'Aktif alert',
            value: summary.activeAlertCount.toString(),
          ),
          _DashboardSummaryItem(
            title: 'Yeni ürün',
            value: summary.newProductCount.toString(),
          ),
        ];
        final width = MediaQuery.sizeOf(context).width;
        final childAspectRatio = width >= 700 ? 2.6 : 1.65;

        return PageContainer(
          maxWidth: 1100,
          child: ListView(
            children: [
              Text(
                'Özet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summaryItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final item = summaryItems[index];

                  return DashboardSummaryCard(
                    title: item.title,
                    value: item.value,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardSummaryItem {
  const _DashboardSummaryItem({required this.title, required this.value});

  final String title;
  final String value;
}
