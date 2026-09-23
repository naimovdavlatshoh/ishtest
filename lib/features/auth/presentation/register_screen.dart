import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  late final TextEditingController _phoneController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final MaskTextInputFormatter _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '### ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    const initialText = '998 ';
    _phoneController = TextEditingController(text: initialText);
    _phoneMaskFormatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: initialText),
    );
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final String phone = _phoneController.text.replaceAll(' ', '');
      await ref.read(authProvider.notifier).register(
            _firstNameController.text,
            _lastNameController.text,
            _emailController.text,
            phone,
            _passwordController.text,
          );
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
                        Text(l10n.authSignUp, style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          l10n.authSignUpSubtitle,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: l10n.authFirstName,
                          hint: l10n.authEnterFirstName,
                          controller: _firstNameController,
                          validator: Validators.name,
                          prefixIcon: const Icon(LucideIcons.user),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.authLastName,
                          hint: l10n.authEnterLastName,
                          controller: _lastNameController,
                          validator: Validators.name,
                          prefixIcon: const Icon(LucideIcons.user),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.authPhoneNumber,
                          hint: l10n.authPhoneHint,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMaskFormatter],
                          validator: Validators.phone,
                          prefixIcon: const Icon(LucideIcons.phone),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.authEmail,
                          hint: l10n.authEnterEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          prefixIcon: const Icon(LucideIcons.mail),
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
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.authConfirmPassword,
                          hint: l10n.authReEnterPassword,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (value) => Validators.confirmPassword(
                              value, _passwordController.text),
                          prefixIcon: const Icon(LucideIcons.lock),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: l10n.authSignUp,
                          onPressed: _handleRegister,
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${l10n.authHasAccount} ",
                                style: AppTextStyles.bodyMedium),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(l10n.authSignIn,
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
