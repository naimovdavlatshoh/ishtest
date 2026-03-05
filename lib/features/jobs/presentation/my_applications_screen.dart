import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/my_applications_provider.dart';
import '../../../shared/models/application_model.dart';
import '../../../core/localization/language_provider.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myApplicationsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myApplicationsProvider);
    final t = ref.watchTr;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('my_applications'),
                            style: AppTextStyles.h2.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            t('track_applications'),
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!state.isLoading && state.applications.isNotEmpty)
                    _buildStatsRow(state.applications),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Content ──────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.applications.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: () => ref.read(myApplicationsProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: state.applications.length,
                            itemBuilder: (context, index) {
                              return _ApplicationCard(
                                application: state.applications[index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<ApplicationModel> apps) {
    final pending = apps.where((a) => a.status == 'pending').length;
    final accepted = apps.where((a) => a.status == 'accepted').length;
    final rejected = apps.where((a) => a.status == 'rejected').length;

    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Jami', value: apps.length, color: const Color(0xFF1D4ED8))),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(label: 'Kutilmoqda', value: pending, color: const Color(0xFFF59E0B))),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(label: 'Qabul', value: accepted, color: const Color(0xFF059669))),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(label: 'Rad', value: rejected, color: const Color(0xFFDC2626))),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text("Hali ariza yo'q", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Vakansiyalar sahifasidan ariza bering',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/jobs'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Vakansiyalarga o't", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Chip — full width ───────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────

class _ApplicationCard extends ConsumerStatefulWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  @override
  ConsumerState<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends ConsumerState<_ApplicationCard> {
  bool _isWithdrawing = false;

  Future<void> _callViewApi(int jobId) async {
    try {
      const s = TokenStorage();
      final token = await s.getAccessToken();
      final url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId/view';
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final job = app.job;

    return GestureDetector(
      onTap: () async {
        if (job != null) {
          await _callViewApi(job.id);
          if (mounted) context.push('/jobs/${job.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top: Icon + Job Info ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job?.title ?? "Vakansiya nomi yo'q",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job?.company?.name ?? 'Company',
                          style: TextStyle(fontSize: 13.5, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (job?.location != null && job!.location.isNotEmpty)
                              _InfoChip(icon: Icons.location_on_outlined, text: job.location),
                            _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              text: 'Ariza yuborilgan ${_formatDate(app.createdAt)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow indicator
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
                ],
              ),

              const SizedBox(height: 14),

              // ─── Status + Withdraw ─────────────────────────────────
              Row(
                children: [
                  _StatusBadge(status: app.status),
                  const Spacer(),
                  if (app.status == 'pending')
                    GestureDetector(
                      onTap: _isWithdrawing
                          ? null
                          : () async {
                              final confirm = await _showConfirmDialog(context);
                              if (confirm == true) {
                                setState(() => _isWithdrawing = true);
                                await ref.read(myApplicationsProvider.notifier).withdraw(app.id);
                                if (mounted) setState(() => _isWithdrawing = false);
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: _isWithdrawing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFDC2626)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Qaytarib olish',
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),

              // ─── Cover Letter ──────────────────────────────────────
              if (app.coverLetter.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF2F4F7)),
                const SizedBox(height: 12),
                Text(
                  "Qo'shma xat:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Text(
                  app.coverLetter,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF344054), height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Arizani qaytarib olish',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Haqiqatan ham bu arizani qaytarib olmoqchimisiz? Bu amalni ortga qaytarib bo'lmaydi.",
                style: TextStyle(fontSize: 13.5, color: Colors.grey[500], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: Text(
                            'Bekor qilish',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Ha, qaytarib olish',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy', 'en').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    Color border;
    String label;
    IconData icon;

    switch (status) {
      case 'accepted':
        color = const Color(0xFF059669);
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFBBF7D0);
        label = 'Qabul qilindi';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFFCDD2);
        label = 'Rad etildi';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        label = "Ko'rib chiqilmoqda";
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
