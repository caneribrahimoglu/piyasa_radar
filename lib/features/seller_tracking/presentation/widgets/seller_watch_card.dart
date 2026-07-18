import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/features/seller_tracking/domain/models/seller_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_card.dart';

class SellerWatchCard extends StatelessWidget {
  const SellerWatchCard({super.key, required this.item, required this.onTap});

  final SellerWatchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.sellerName,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Pazaryeri', value: item.marketplaceName),
          _InfoRow(label: 'Toplam ürün', value: item.totalProducts.toString()),
          _InfoRow(label: 'Yeni ürün', value: item.newProductsCount.toString()),
          _InfoRow(label: 'Son kontrol', value: item.formattedLastCheckedAt),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: const Text('Detay'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
