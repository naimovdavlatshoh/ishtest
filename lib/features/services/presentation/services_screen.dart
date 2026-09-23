import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/widgets/loaders/app_loader.dart';
import 'package:linkedin_clone/core/widgets/empty_states/empty_state.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import '../providers/services_provider.dart';
import '../widgets/service_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        ref.read(servicesProvider.notifier).setSearch(query);
      } else if (query.isEmpty) {
        ref.read(servicesProvider.notifier).setSearch(null);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(servicesProvider);
      if (!state.isLoading && !state.isMoreLoading && state.services.length < state.total) {
        ref.read(servicesProvider.notifier).loadMore();
      }
    }
  }

  void _showCategoryDialog(ServicesFilters current) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Kategoriya tanlang"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: serviceCategoryLabels.entries.map((e) => ListTile(
              title: Text(e.value),
              trailing: current.category == e.key ? const Icon(LucideIcons.circleCheck, color: AppColors.primary) : null,
              onTap: () {
                ref.read(servicesProvider.notifier).updateFilters(current.copyWith(category: e.key));
                Navigator.of(dialogContext).pop();
              },
            )).toList(),
          ),
        ),
        actions: [
          if (current.category != null)
            TextButton(
              onPressed: () {
                ref.read(servicesProvider.notifier).updateFilters(current.copyWith(clearCategory: true));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tozalash'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Xizmatlarni qidirish...',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.iconSecondary, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push('/services/add'),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(LucideIcons.plus, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.divider))),
            child: GestureDetector(
              onTap: () => _showCategoryDialog(state.filters),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: state.filters.category != null ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.filters.category != null
                          ? (serviceCategoryLabels[state.filters.category] ?? state.filters.category!)
                          : 'Kategoriya',
                      style: TextStyle(
                        color: state.filters.category != null ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronDown, size: 16, color: state.filters.category != null ? Colors.white70 : AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildList(state)),
        ],
      ),
    );
  }

  Widget _buildList(ServicesState state) {
    if (state.isLoading && state.services.isEmpty) {
      return const AppLoader();
    }

    if (state.services.isEmpty) {
      return EmptyState(
        icon: LucideIcons.wrench,
        title: 'Xizmatlar topilmadi',
        message: "Boshqa qidiruv yoki kategoriya bilan urinib ko'ring",
        actionText: 'Yangilash',
        onAction: () => ref.read(servicesProvider.notifier).refreshServices(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(servicesProvider.notifier).refreshServices(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: state.services.length + (state.isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.services.length) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
            );
          }
          final ServiceModel service = state.services[index];
          return ServiceCard(
            service: service,
            onTap: () => context.push('/services/${service.id}', extra: service),
          );
        },
      ),
    );
  }
}
