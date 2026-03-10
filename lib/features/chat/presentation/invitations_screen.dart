import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../providers/invitations_provider.dart';

class InvitationsScreen extends ConsumerStatefulWidget {
  const InvitationsScreen({super.key});

  @override
  ConsumerState<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends ConsumerState<InvitationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(invitationsProvider.notifier).loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invitationsProvider);
    final l10n = AppLocalizations.of(context)!;
    final receivedCount = state.received.length;
    final sentCount = state.sent.length;

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
                        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        l10n.invitationsTitle,
                        style: AppTextStyles.h2.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.invitationsSubtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Custom Tab Bar ───────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey[500],
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.invitationsTabReceived),
                              if (receivedCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$receivedCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.invitationsTabSent),
                              if (sentCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$sentCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tab Content ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ReceivedTab(state: state),
                  _SentTab(state: state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Received Tab ─────────────────────────────────────────────────────────────

class _ReceivedTab extends ConsumerWidget {
  final InvitationsState state;
  const _ReceivedTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoadingReceived) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.received.isEmpty) {
      return _buildEmpty(l10n.invitationsEmptyReceived, Icons.mark_email_unread_outlined);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(invitationsProvider.notifier).loadReceived(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.received.length,
        itemBuilder: (context, index) {
          final inv = state.received[index];
          return _ReceivedCard(invitation: inv);
        },
      ),
    );
  }

  Widget _buildEmpty(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
        ],
      ),
    );
  }
}

// ─── Sent Tab ─────────────────────────────────────────────────────────────────

class _SentTab extends ConsumerWidget {
  final InvitationsState state;
  const _SentTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.sent.isEmpty) {
      return _buildEmpty(l10n.invitationsEmptySent, Icons.send_outlined);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(invitationsProvider.notifier).loadSent(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.sent.length,
        itemBuilder: (context, index) {
          final inv = state.sent[index];
          return _SentCard(invitation: inv);
        },
      ),
    );
  }

  Widget _buildEmpty(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
        ],
      ),
    );
  }
}

// ─── Received Card ────────────────────────────────────────────────────────────

class _ReceivedCard extends ConsumerStatefulWidget {
  final InvitationModel invitation;
  const _ReceivedCard({required this.invitation});

  @override
  ConsumerState<_ReceivedCard> createState() => _ReceivedCardState();
}

class _ReceivedCardState extends ConsumerState<_ReceivedCard> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.invitation;
    final l10n = AppLocalizations.of(context)!;
    final from = inv.fromUser;
    final avatarUrl = from?.avatar?.fullImageUrl;
    final initials = from?.initials ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFEEF2FF)],
                    ),
                    image: avatarUrl != null && avatarUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Center(
                          child: Text(initials,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 19)))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.invitationsWantsToChat(from?.fullName ?? l10n.invitationsUnknownUser),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
                      ),
                      const SizedBox(height: 5),
                      if (inv.message.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${inv.message}"',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF1D4ED8), fontStyle: FontStyle.italic),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(inv.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Buttons based on status ──────────────────────────
            if (inv.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: l10n.invitationsAccept,
                      icon: Icons.check_rounded,
                      isPrimary: true,
                      isLoading: _isAccepting,
                      onTap: () async {
                        setState(() => _isAccepting = true);
                        final ok = await ref.read(invitationsProvider.notifier).accept(inv.id);
                        if (mounted) setState(() => _isAccepting = false);
                        if (ok && mounted && inv.conversationId != null) {
                          context.push('/chat/${inv.conversationId}');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: l10n.invitationsReject,
                      icon: Icons.close_rounded,
                      isPrimary: false,
                      isLoading: _isRejecting,
                      onTap: () async {
                        setState(() => _isRejecting = true);
                        await ref.read(invitationsProvider.notifier).reject(inv.id);
                        if (mounted) setState(() => _isRejecting = false);
                      },
                    ),
                  ),
                ],
              )
            else
              _StatusBadge(status: inv.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─── Sent Card ────────────────────────────────────────────────────────────────

class _SentCard extends ConsumerWidget {
  final InvitationModel invitation;
  const _SentCard({required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inv = invitation;
    final to = inv.toUser;
    final avatarUrl = to?.avatar?.fullImageUrl;
    final initials = to?.initials ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                image: avatarUrl != null && avatarUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Center(
                      child: Text(initials,
                          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 19)))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.invitationsPrefix(to?.fullName ?? l10n.invitationsUnknownUser),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 6),
                  if (inv.message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        '"${inv.message}"',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF344054), fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.send_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        l10n.invitationsSentAt(_formatDate(inv.createdAt)),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _StatusBadge(status: inv.status, small: true),
                  // If accepted → show open chat button
                  if (inv.status == 'accepted' && inv.conversationId != null) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => ctx.push('/chat/${inv.conversationId}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 15),
                              const SizedBox(width: 6),
                              Text(l10n.invitationsOpenChat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
          boxShadow: isPrimary
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: isPrimary ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  const _StatusBadge({required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    // Add Consumer support or pass t. But wait, _StatusBadge is a StatelessWidget, let's just make it ConsumerWidget or use context directly.
    return Consumer(
      builder: (context, ref, child) {
        Color color;
        Color bg;
        String label;
        IconData icon;

        switch (status) {
          case 'accepted':
            color = const Color(0xFF059669);
            bg = const Color(0xFFECFDF5);
            label = AppLocalizations.of(context)!.invitationsAccepted;
            icon = Icons.check_circle_outline_rounded;
            break;
          case 'rejected':
            color = const Color(0xFFDC2626);
            bg = const Color(0xFFFEF2F2);
            label = AppLocalizations.of(context)!.invitationsRejected;
            icon = Icons.cancel_outlined;
            break;
          default:
            color = const Color(0xFFF59E0B);
            bg = const Color(0xFFFFFBEB);
            label = AppLocalizations.of(context)!.invitationsPending;
            icon = Icons.schedule_rounded;
        }

        if (small) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}
