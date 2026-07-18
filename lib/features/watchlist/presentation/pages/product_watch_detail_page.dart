import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/theme/app_radius.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class ProductWatchDetailPage extends StatelessWidget {
  const ProductWatchDetailPage({super.key, required this.item});

  final ProductWatchItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.productName)),
      body: PageContainer(
        maxWidth: 800,
        child: ListView(
          children: [
            Text(
              item.productName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'Ürün linki', value: item.productUrl),
            _DetailRow(
              label: 'Kontrol saatleri',
              value: item.formattedCheckTimes,
            ),
            _DetailRow(label: 'Pazaryeri/Site', value: item.marketplaceName),
            _DetailRow(label: 'Satıcı adı', value: item.sellerName),
            _DetailRow(label: 'Son fiyat', value: item.formattedLastPrice),
            _DetailRow(
              label: 'Önceki fiyat',
              value: item.formattedPreviousPrice,
            ),
            _DetailRow(
              label: 'Son kontrol zamanı',
              value: item.formattedLastCheckedAt,
            ),
            _DetailRow(label: 'Stok durumu', value: item.stockLabel),
            _DetailRow(
              label: 'Fiyat durumu',
              value: item.priceChanged ? 'Fiyat değişti' : 'Fiyat değişmedi',
            ),
            const SizedBox(height: AppSpacing.lg),
            _AlertHistory(alerts: item.alerts),
          ],
        ),
      ),
    );
  }
}

class _AlertHistory extends StatelessWidget {
  const _AlertHistory({required this.alerts});

  final List<AlertEvent> alerts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Geçmişi',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (alerts.isEmpty)
          Text('Henüz alert yok', style: textTheme.bodyMedium)
        else
          ...alerts.map((alert) => _AlertEventTile(alert: alert)),
      ],
    );
  }
}

class _AlertEventTile extends StatelessWidget {
  const _AlertEventTile({required this.alert});

  final AlertEvent alert;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(alert.message),
              const SizedBox(height: AppSpacing.sm),
              Text(
                alert.formattedCreatedAt,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
