import 'package:flutter/material.dart';
import 'package:piyasa_radar/app/app_state.dart';
import 'package:piyasa_radar/core/theme/app_radius.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/core/tracking/tracking_check_status.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/alert_event.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/add_product_watch_page.dart';
import 'package:piyasa_radar/shared/widgets/page_container.dart';

class ProductWatchDetailPage extends StatefulWidget {
  const ProductWatchDetailPage({
    required this.item,
    required this.appState,
    super.key,
  });

  final ProductWatchItem item;
  final AppState appState;

  @override
  State<ProductWatchDetailPage> createState() => _ProductWatchDetailPageState();
}

class _ProductWatchDetailPageState extends State<ProductWatchDetailPage> {
  late ProductWatchItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEditPage(BuildContext context) async {
    final updatedItem = await Navigator.of(context).push<ProductWatchItem>(
      MaterialPageRoute(
        builder: (context) => AddProductWatchPage(initialItem: _item),
      ),
    );

    if (updatedItem == null || !context.mounted) return;

    await widget.appState.updateWatchItem(updatedItem);
    if (!context.mounted) return;

    setState(() => _item = updatedItem);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ürün takibi güncellendi.')));
  }

  Future<void> _confirmRemoval(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Takipten çıkar'),
        content: const Text(
          'Bu ürünü takipten çıkarmak istediğinize emin misiniz?',
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
    await widget.appState.removeWatchItem(_item.id);
    if (context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.productName),
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
              _item.productName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'Ürün linki', value: _item.productUrl),
            _DetailRow(
              label: 'Kontrol saatleri',
              value: _item.formattedCheckTimes,
            ),
            _DetailRow(label: 'Pazaryeri/Site', value: _item.marketplaceName),
            _DetailRow(label: 'Satıcı adı', value: _item.sellerName),
            _DetailRow(label: 'Hedef fiyat', value: _item.formattedTargetPrice),
            _DetailRow(label: 'Son fiyat', value: _item.formattedLastPrice),
            _DetailRow(
              label: 'Önceki fiyat',
              value: _item.formattedPreviousPrice,
            ),
            _DetailRow(label: 'Kontrol durumu', value: _item.checkStatusLabel),
            _DetailRow(
              label: 'Son kontrol zamanı',
              value: _item.formattedLastCheckedAt,
            ),
            if (_item.checkStatus == TrackingCheckStatus.failed &&
                (_item.lastCheckError?.trim().isNotEmpty ?? false))
              _DetailRow(label: 'Kontrol hatası', value: _item.lastCheckError!),
            _DetailRow(
              label: 'Stok takibi',
              value: _item.stockTrackingEnabled ? 'Aktif' : 'Kapalı',
            ),
            _DetailRow(
              label: 'Stok durumu',
              value: _item.stockTrackingEnabled
                  ? _item.stockLabel
                  : 'Kontrol edilmiyor',
            ),
            _DetailRow(
              label: 'Fiyat durumu',
              value: _item.priceChanged ? 'Fiyat değişti' : 'Fiyat değişmedi',
            ),
            const SizedBox(height: AppSpacing.lg),
            _AlertHistory(alerts: _item.alerts),
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
