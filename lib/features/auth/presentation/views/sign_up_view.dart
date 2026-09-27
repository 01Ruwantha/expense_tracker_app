import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../routing/app_router.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the Terms of Service to continue.')),
      );
      return;
    }
    final success = await ref.read(authViewModelProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.signIn),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: colorScheme.onSurface, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Header ──────────────────────────────────────────────────
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        size: 30, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.createAccount, style: textTheme.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Start tracking your expenses and achieve your financial goals',
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── Form ─────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerLowest
                      : AppColors.lightSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error
                      if (authState.errorMessage != null) ...[
                        _buildErrorBanner(authState.errorMessage!, colorScheme,
                            textTheme),
                        const SizedBox(height: 16),
                      ],

                      // Full Name
                      _buildField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        hint: 'Alex Morgan',
                        icon: Icons.person_outline_rounded,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        validator: (v) => v == null || v.isEmpty
                            ? AppStrings.fieldRequired
                            : null,
                        inputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildField(
                        controller: _emailController,
                        label: AppStrings.email,
                        hint: 'name@domain.com',
                        icon: Icons.mail_outline_rounded,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v)) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                        inputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildPasswordField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        obscure: _obscurePassword,
                        onToggle: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (v.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                        inputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (v != _passwordController.text) {
                            return AppStrings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                        inputAction: TextInputAction.done,
                        onSubmit: (_) => _signUp(),
                      ),
                      const SizedBox(height: 16),

                      // Terms checkbox
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 2),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _agreedToTerms
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: AppStrings.termsOfService,
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: AppStrings.privacyPolicy,
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up button
                      FilledButton(
                        onPressed: authState.isLoading ? null : _signUp,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppStrings.signUp,
                                style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Sign In link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.signIn),
                    child: Text(
                      AppStrings.signIn,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    TextInputType? keyboardType,
    TextInputAction? inputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: inputAction,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    TextInputAction? inputAction,
    void Function(String)? onSubmit,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textInputAction: inputAction,
          onFieldSubmitted: onSubmit,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: '••••••••••••',
            prefixIcon: Icon(Icons.lock_outline_rounded,
                color: colorScheme.onSurfaceVariant, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(
      String message, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
