import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/app_header/app_header.dart';
import '../widgets/auth_text_field.dart';
import '../providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final String identifier = _identifierController.text.trim();
      await ref
          .read(authProvider.notifier)
          .login(identifier, _passwordController.text);

      if (!mounted) return;
      final AuthState authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        context.go('/feed');
      } else if (authState.errorMessage != null) {
        context.showSnackBar(authState.errorMessage!, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(
              height: 216,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const AppHeaderBand(height: 216),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 22,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AppLogoBadge(
                        size: 88,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            'assets/images/ishlogo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ish',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
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
                        Text(l10n.authWelcome, style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          l10n.authSignIn,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: l10n.authPhoneOrEmail,
                          hint: l10n.authPhoneOrEmailHint,
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? l10n.jobFormErrorRequired
                                  : null,
                          prefixIcon: const Icon(LucideIcons.user),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.authPassword,
                          hint: l10n.authEnterPassword,
                          controller: _passwordController,
                          isPassword: true,
                          validator: Validators.password,
                          prefixIcon: const Icon(LucideIcons.lock),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(l10n.authForgotPassword,
                                style: AppTextStyles.link),
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: l10n.authSignIn,
                          onPressed: _handleLogin,
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(l10n.authOr,
                                  style: AppTextStyles.caption),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${l10n.authNoAccount} ",
                                style: AppTextStyles.bodyMedium),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: Text(l10n.authSignUp,
                                  style: AppTextStyles.link),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
