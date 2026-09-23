import 'package:flutter/material.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ServiceCard({super.key, required this.service, this.onTap, this.trailing});

  String _formatPrice(ServiceModel s) {
    if (s.priceType == 'negotiable' && s.priceMin == null && s.priceMax == null) {
      return "Kelishiladi";
    }
    final String suffix = s.priceType == 'hourly' ? '/soat' : '';
    if (s.priceMin != null && s.priceMax != null) {
      return '${s.priceMin} - ${s.priceMax} ${s.priceCurrency}$suffix';
    } else if (s.priceMin != null) {
      return '${s.priceMin}+ ${s.priceCurrency}$suffix';
    } else if (s.priceMax != null) {
      return "${s.priceMax} ${s.priceCurrency}$suffix gacha";
    }
    return servicePriceTypeLabels[s.priceType] ?? 'Kelishiladi';
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = serviceCategoryLabels[service.category] ?? service.category;
    final hasImage = service.image != null && service.image!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    service.image!.fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(LucideIcons.image, color: AppColors.textTertiary, size: 32),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!hasImage) ...[
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.wrench, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.title, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary, height: 1.2)),
                              const SizedBox(height: 4),
                              Text(categoryLabel, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildTag(LucideIcons.mapPin, service.location, maxWidth: 220),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatPrice(service),
                      style: AppTextStyles.label.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(LucideIcons.eye, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text('${service.viewsCount}', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, {Color? color, double? maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? AppColors.textTertiary).withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? AppColors.textTertiary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: color ?? AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
