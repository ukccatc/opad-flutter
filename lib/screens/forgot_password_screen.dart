import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/password_reset_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordResetService = PasswordResetService();
  bool _isLoading = false;
  String? _error;
  bool _emailSent = false;
  String? _userEmail;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _emailSent = false;
    });

    try {
      final email = _emailController.text.trim();

      // Send password reset email
      final token = await _passwordResetService.sendPasswordResetEmail(email);

      if (token != null) {
        setState(() {
          _emailSent = true;
          _userEmail = email;
          _resetToken = token;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Користувача з таким email не знайдено. Перевірте правильність введеного email.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        String errorMessage = 'Помилка при відправці email';

        // Handle rate limit exception - show user-friendly message
        if (e is RateLimitException) {
          errorMessage = e.toLocalizedString();
        } else {
          // Provide more specific error messages
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('insufficient authentication') ||
              errorString.contains('authentication scopes')) {
            errorMessage =
                'Помилка авторизації Gmail. Перевірте налаштування EmailJS сервісу.';
          } else if (errorString.contains('template') ||
              errorString.contains('template_id')) {
            errorMessage =
                'Помилка шаблону email. Перевірте Template ID в EmailJS.';
          } else if (errorString.contains('service') ||
              errorString.contains('service_id')) {
            errorMessage =
                'Помилка сервісу email. Перевірте Service ID в EmailJS.';
          } else if (errorString.contains('status')) {
            errorMessage =
                'Помилка відправки email. Перевірте налаштування EmailJS.';
          } else {
            errorMessage = 'Помилка при відправці email: ${e.toString()}';
          }
        }

        _error = errorMessage;
        _isLoading = false;
        _emailSent = false; // Reset email sent state on error
      });

      // Also print to console for debugging
      print('Error in forgot password screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Відновлення пароля'), elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 56,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Забули пароль?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Введіть вашу електронну пошту для відновлення пароля',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Електронна пошта',
                        hintText: 'example@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleResetPassword(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Будь ласка, введіть вашу електронну пошту';
                        }
                        if (!value.contains('@')) {
                          return 'Будь ласка, введіть дійсну електронну пошту';
                        }
                        return null;
                      },
                    ),
                    // Email Sent Success Message
                    if (_emailSent && _userEmail != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Email відправлено',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ми надіслали інструкції для відновлення пароля на вашу електронну пошту:',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _userEmail!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Перевірте вашу поштову скриньку та перейдіть за посиланням у листі для встановлення нового пароля.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Якщо ви не отримали email, перевірте папку "Спам" або спробуйте ще раз через кілька хвилин.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            // Development: Show reset link if token is available
                            if (_resetToken != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Для розробки (посилання для відновлення):',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onTertiaryContainer,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      _passwordResetService.getResetLink(
                                        _userEmail!,
                                        _resetToken!,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    // Error Message
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _error!.contains('Занадто багато запитів')
                                        ? 'Занадто багато запитів'
                                        : 'Помилка',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Check Email Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                'Відправити інструкції',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Back to Login Link
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Повернутися до входу'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
