import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/password_reset_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordResetService = PasswordResetService();
  bool _isLoading = false;
  String? _error;
  bool _passwordReset = false;
  bool _isTokenValid = false;
  bool _isVerifyingToken = true;

  @override
  void initState() {
    super.initState();
    // Debug: Print received parameters
    print('ResetPasswordScreen initialized');
    print('Email from widget: ${widget.email}');
    print('Token from widget: ${widget.token}');
    
    // Check if parameters are empty
    if (widget.email.isEmpty || widget.token.isEmpty) {
      setState(() {
        _error = 'Посилання для відновлення пароля некоректне. Перевірте правильність посилання або запросіть нове.';
      });
      return;
    }
    
    _verifyToken();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    // go_router automatically decodes query parameters, so widget.email should already be decoded
    // But we'll use it as-is since the service normalizes email internally
    print('Verifying token for email: ${widget.email}');
    print('Token: ${widget.token}');
    
    final isValid = await _passwordResetService.verifyResetToken(
      widget.email,
      widget.token,
    );

    print('Token verification result: $isValid');

    if (mounted) {
      setState(() {
        _isVerifyingToken = false;
        _isTokenValid = isValid;
        if (!isValid) {
          _error =
              'Посилання для відновлення пароля недійсне або застаріле. Запросите нове посилання.';
        }
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = 'Паролі не співпадають';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // go_router automatically decodes query parameters
      print('Updating password for email: ${widget.email}');
      
      final success = await _passwordResetService.updatePassword(
        widget.email,
        widget.token,
        _passwordController.text,
      );

      if (success) {
        setState(() {
          _passwordReset = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Помилка при зміні пароля. Посилання може бути недійсним або застарілим.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Помилка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Встановлення нового пароля'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _passwordReset
                  ? _buildSuccessView()
                  : _isVerifyingToken
                      ? _buildLoadingView()
                      : !_isTokenValid
                          ? _buildErrorView()
                          : Form(
                              key: _formKey,
                              child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 56,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Встановлення нового пароля',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Введіть новий пароль для вашого облікового запису',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // New Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Новий пароль',
                              prefixIcon: Icon(Icons.lock_outline),
                              filled: true,
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть новий пароль';
                              }
                              if (value.length < 6) {
                                return 'Пароль повинен містити мінімум 6 символів';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Підтвердіть пароль',
                              prefixIcon: Icon(Icons.lock_outline),
                              filled: true,
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleResetPassword(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, підтвердіть пароль';
                              }
                              if (value != _passwordController.text) {
                                return 'Паролі не співпадають';
                              }
                              return null;
                            },
                          ),
                          // Error Message
                          if (_error != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Reset Password Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleResetPassword,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                      'Встановити новий пароль',
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

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Перевірка посилання...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Посилання недійсне',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error ??
                      'Посилання для відновлення пароля недійсне або застаріле. Запросите нове посилання.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/forgot-password'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Запросити нове посилання',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Повернутися до входу'),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Пароль успішно змінено!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Ваш пароль було успішно змінено. Тепер ви можете увійти з новим паролем.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Перейти до входу',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
