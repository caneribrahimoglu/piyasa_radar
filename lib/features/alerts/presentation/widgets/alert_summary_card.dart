import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/features/alerts/domain/models/alert_summary_item.dart';
import 'package:piyasa_radar/shared/widgets/app_card.dart';

class AlertSummaryCard extends StatelessWidget {
  const AlertSummaryCard({required this.item, required this.onTap, super.key});

  final AlertSummaryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final emphasis = item.isRead ? FontWeight.w500 : FontWeight.w700;
    final sourceLabel = item.sourceType == 'product' ? 'Ürün' : 'Satıcı';

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!item.isRead) ...[
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  item.title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: emphasis),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sourceLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.message, style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Kaynak: ${item.sourceName}',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
              Text(
                item.formattedCreatedAt,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
