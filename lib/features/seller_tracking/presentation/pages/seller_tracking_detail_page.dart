import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/theme/app_radius.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_alert_event.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_product_item.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/features/seller_tracking/presentation/pages/add_seller_watch_page.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class SellerTrackingDetailPage extends StatefulWidget {
  const SellerTrackingDetailPage({
    required this.item,
    required this.appState,
    super.key,
  });

  final SellerWatchItem item;
  final AppState appState;

  @override
  State<SellerTrackingDetailPage> createState() =>
      _SellerTrackingDetailPageState();
}

class _SellerTrackingDetailPageState extends State<SellerTrackingDetailPage> {
  late SellerWatchItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEditPage(BuildContext context) async {
    final updatedItem = await Navigator.of(context).push<SellerWatchItem>(
      MaterialPageRoute(
        builder: (context) => AddSellerWatchPage(initialItem: _item),
      ),
    );

    if (updatedItem == null || !context.mounted) return;

    await widget.appState.updateSellerItem(updatedItem);
    if (!context.mounted) return;

    setState(() => _item = updatedItem);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Satıcı takibi güncellendi.')));
  }

  Future<void> _confirmRemoval(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Takipten çıkar'),
        content: const Text(
          'Bu satıcıyı takipten çıkarmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Takipten Çıkar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await widget.appState.removeSellerItem(_item.id);
    if (context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satıcı Detayı'),
        actions: [
          IconButton(
            tooltip: 'Düzenle',
            onPressed: () => _openEditPage(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Takipten çıkar',
            onPressed: () => _confirmRemoval(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: PageContainer(
        maxWidth: 800,
        child: ListView(
          children: [
            Text(
              _item.sellerName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'Pazaryeri', value: _item.marketplaceName),
            _DetailRow(label: 'Satıcı linki', value: _item.sellerUrl),
            _DetailRow(
              label: 'Kontrol saatleri',
              value: _item.formattedCheckTimes,
            ),
            _DetailRow(
              label: 'Toplam ürün sayısı',
              value: _item.totalProducts.toString(),
            ),
            _DetailRow(
              label: 'Yeni ürün sayısı',
              value: _item.newProductsCount.toString(),
            ),
            _DetailRow(label: 'Kontrol durumu', value: _item.checkStatusLabel),
            _DetailRow(
              label: 'Son kontrol zamanı',
              value: _item.formattedLastCheckedAt,
            ),
            if (_item.checkStatus == TrackingCheckStatus.failed &&
                (_item.lastCheckError?.trim().isNotEmpty ?? false))
              _DetailRow(label: 'Kontrol hatası', value: _item.lastCheckError!),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Ürün Listesi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._item.products.map((product) {
              return _SellerProductTile(product: product);
            }),
            const SizedBox(height: AppSpacing.lg),
            _SellerAlertHistory(alerts: _item.alerts),
          ],
        ),
      ),
    );
  }
}

class _SellerAlertHistory extends StatelessWidget {
  const _SellerAlertHistory({required this.alerts});

  final List<SellerAlertEvent> alerts;

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
          ...alerts.map((alert) => _SellerAlertTile(alert: alert)),
      ],
    );
  }
}

class _SellerAlertTile extends StatelessWidget {
  const _SellerAlertTile({required this.alert});

  final SellerAlertEvent alert;

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

class _SellerProductTile extends StatelessWidget {
  const _SellerProductTile({required this.product});

  final SellerProductItem product;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (product.isNew) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _NewProductLabel(),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(product.formattedPrice),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.formattedDetectedAt,
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

class _NewProductLabel extends StatelessWidget {
  const _NewProductLabel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Yeni ürün',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
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
