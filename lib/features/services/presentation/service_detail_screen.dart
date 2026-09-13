import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import 'package:linkedin_clone/features/services/providers/services_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final ServiceModel? service;
  final int? serviceId;

  const ServiceDetailScreen({super.key, this.service, this.serviceId})
      : assert(service != null || serviceId != null);

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  ServiceModel? _service;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    if (_service == null && widget.serviceId != null) {
      _loadService();
    }
  }

  Future<void> _loadService() async {
    setState(() => _isLoading = true);
    final service = await ref.read(servicesProvider.notifier).getServiceById(widget.serviceId!);
    if (mounted) {
      setState(() {
        _service = service;
        _isLoading = false;
      });
    }
  }

  String _authorName(ServiceModel service) {
    final author = service.author;
    if (author == null) return 'Foydalanuvchi';
    final name = '${author.firstName} ${author.lastName}'.trim();
    return name.isEmpty ? 'Foydalanuvchi' : name;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatPrice(ServiceModel s) {
    if (s.priceType == 'negotiable' && s.priceMin == null && s.priceMax == null) {
      return 'Kelishiladi';
    }
    final String suffix = s.priceType == 'hourly' ? '/soat' : '';
    if (s.priceMin != null && s.priceMax != null) {
      return '${s.priceMin} - ${s.priceMax} ${s.priceCurrency}$suffix';
    } else if (s.priceMin != null) {
      return '${s.priceMin}+ ${s.priceCurrency}$suffix';
    } else if (s.priceMax != null) {
      return '${s.priceMax} ${s.priceCurrency}$suffix gacha';
    }
    return servicePriceTypeLabels[s.priceType] ?? 'Kelishiladi';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Xizmat topilmadi')),
      );
    }

    final service = _service!;
    final hasImage = service.image != null && service.image!.isNotEmpty;
    final categoryLabel = serviceCategoryLabels[service.category] ?? service.category;
    final avatarUrl = service.author?.avatar;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
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
                    child: const Icon(LucideIcons.image, color: AppColors.textTertiary, size: 48),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!hasImage) ...[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(LucideIcons.wrench, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.title, style: AppTextStyles.h2.copyWith(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(categoryLabel, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildIconLabel(LucideIcons.mapPin, service.location),
                      _buildIconLabel(LucideIcons.calendar, _formatDate(service.createdAt)),
                      _buildIconLabel(LucideIcons.eye, '${service.viewsCount}'),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
                  Text('Narx', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(_formatPrice(service), style: AppTextStyles.h2.copyWith(color: AppColors.success, fontSize: 20)),
                  const SizedBox(height: 28),
                  Text('Tavsif', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text(
                    service.description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textPrimary.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 28),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text('Xizmat ko\'rsatuvchi', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => context.push('/profile/${service.authorId}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? NetworkImage(avatarUrl.fullImageUrl)
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? Text(
                                  _authorName(service).isNotEmpty ? _authorName(service)[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_authorName(service), style: AppTextStyles.username),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: color ?? AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
