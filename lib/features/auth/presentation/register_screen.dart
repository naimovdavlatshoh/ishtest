import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../providers/auth_provider.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authState.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/ishlogo.png',
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ish',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Text('Ro\'yxatdan o\'tish', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Ro\'yxatdan o\'tish',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  label: 'Ism',
                  hint: 'Ismingizni kiriting',
                  controller: _firstNameController,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Familiya',
                  hint: 'Familiyangizni kiriting',
                  controller: _lastNameController,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Telefon raqami',
                  hint: '998 90 123 45 67',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMaskFormatter],
                  validator: Validators.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Elektron pochta',
                  hint: 'Emailingizni kiriting',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Parol',
                  hint: 'Parolni kiriting',
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Parolni tasdiqlang',
                  hint: 'Parolni qayta kiriting',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Ro\'yxatdan o\'tish',
                  onPressed: _handleRegister,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${'Akkauntingiz bormi?'} ", style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('Tizimga kirish', style: AppTextStyles.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
