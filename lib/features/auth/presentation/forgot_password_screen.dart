import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/atlas/atlas_pattern.dart';
import '../widgets/auth_text_field.dart';
import '../providers/password_reset_provider.dart';

/// Two-step "forgot password" flow on a single screen:
/// 1. Enter the registered email -> POST /auth/forgot-password.
/// 2. Enter the code that was emailed plus a new password (typed twice)
///    -> POST /auth/reset-password, then back to the login screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _codeSent = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final String email = _emailController.text.trim();

    final bool success = await ref.read(passwordResetProvider.notifier).requestCode(email);
    if (!mounted) return;

    if (success) {
      setState(() {
        _codeSent = true;
        _sentEmail = email;
      });
      context.showSnackBar(l10n.forgotPasswordCodeSentMsg(email));
    } else {
      final String? error = ref.read(passwordResetProvider).errorMessage;
      context.showSnackBar(error ?? l10n.errorOccurred, isError: true);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final bool success = await ref.read(passwordResetProvider.notifier).resetPassword(
          email: _sentEmail,
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;

    if (success) {
      context.showSnackBar(l10n.forgotPasswordSuccessMsg);
      context.go('/login');
    } else {
      final String? error = ref.read(passwordResetProvider).errorMessage;
      context.showSnackBar(error ?? l10n.errorOccurred, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final PasswordResetState state = ref.watch(passwordResetProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 216,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const AtlasBand(height: 216, archDepth: 26, archCount: 3, tileSize: 115),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: _RoundIconButton(
                    icon: LucideIcons.arrowLeft,
                    onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 22,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AtlasMedallion(
                      size: 88,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(LucideIcons.keyRound, size: 32, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.forgotPasswordTitle, style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      Text(
                        _codeSent
                            ? l10n.forgotPasswordCodeSentMsg(_sentEmail)
                            : l10n.forgotPasswordSubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      if (!_codeSent) ...[
                        AuthTextField(
                          label: l10n.authEmail,
                          hint: l10n.authEnterEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          prefixIcon: const Icon(LucideIcons.mail),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: l10n.forgotPasswordSendCodeBtn,
                          onPressed: _handleSendCode,
                          isLoading: state.isLoading,
                        ),
                      ] else ...[
                        AuthTextField(
                          label: l10n.forgotPasswordCodeLabel,
                          hint: l10n.forgotPasswordCodeHint,
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty
                              ? l10n.jobFormErrorRequired
                              : null,
                          prefixIcon: const Icon(LucideIcons.shieldCheck),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.forgotPasswordNewPasswordLabel,
                          hint: l10n.forgotPasswordNewPasswordHint,
                          controller: _newPasswordController,
                          isPassword: true,
                          validator: Validators.password,
                          prefixIcon: const Icon(LucideIcons.lock),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.forgotPasswordConfirmNewPasswordLabel,
                          hint: l10n.forgotPasswordConfirmNewPasswordHint,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (value) =>
                              Validators.confirmPassword(value, _newPasswordController.text),
                          prefixIcon: const Icon(LucideIcons.lock),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: l10n.forgotPasswordResetBtn,
                          onPressed: _handleResetPassword,
                          isLoading: state.isLoading,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 19, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
