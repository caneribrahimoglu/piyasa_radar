import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/theme/app_colors.dart';
import 'package:piyasa_radar/core/theme/app_radius.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/shared/widgets/app_card.dart';

class ProductWatchCard extends StatelessWidget {
  const ProductWatchCard({super.key, required this.item, required this.onTap});

  final ProductWatchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceDownColor = isDark
        ? AppColors.priceDownDark
        : AppColors.priceDownLight;
    final priceUpColor = isDark
        ? AppColors.priceUpDark
        : AppColors.priceUpLight;
    final stockColor = item.inStock ? priceDownColor : colorScheme.error;
    final priceColor = item.priceDecreased
        ? priceDownColor
        : item.priceIncreased
        ? priceUpColor
        : colorScheme.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (item.priceChanged) ...[
                const SizedBox(width: AppSpacing.sm),
                _PriceChangedLabel(color: priceColor),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Pazaryeri', value: item.marketplaceName),
          _InfoRow(label: 'Satıcı', value: item.sellerName),
          _InfoRow(label: 'Son kontrol', value: item.formattedLastCheckedAt),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son fiyat',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      item.formattedLastPrice,
                      style: textTheme.titleMedium?.copyWith(
                        color: priceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Önceki fiyat',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item.formattedPreviousPrice,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.stockLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: stockColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onTap, child: const Text('Detay')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceChangedLabel extends StatelessWidget {
  const _PriceChangedLabel({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Fiyat değişti',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
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
