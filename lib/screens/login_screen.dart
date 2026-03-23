import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      final login = await _authService.getLogin();
      if (login != null && login.isNotEmpty) {
        context.go('/stats?login=$login');
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ [LOGIN] Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _loginController.text.trim();
      final password = _passwordController.text;

      print('🔐 [LOGIN] Attempting login for: $email');
      print('🔐 [LOGIN] Password length: ${password.length}');

      final success = await _apiService.authenticatePerson(email, password);

      print('🔐 [LOGIN] Authentication result: $success');

      if (success) {
        print('✅ [LOGIN] Login successful for: $email');
        await _authService.saveLogin(email);
        print('💾 [LOGIN] Login saved to storage');

        if (mounted) {
          print('🔄 [LOGIN] Navigating to stats page');
          context.go('/stats?login=$email');
        }
      } else {
        print('❌ [LOGIN] Authentication failed - invalid credentials');
        setState(() {
          _error = 'Невірний логін або пароль';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [LOGIN] Login error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід'), elevation: 0),
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
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Особистий вхід',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Введіть ваш email та пароль для продовження',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Email Field
                    TextFormField(
                      controller: _loginController,
                      decoration: InputDecoration(
                        labelText: 'Електронна пошта',
                        hintText: 'example@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                        filled: true,
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Будь ласка, введіть ваш пароль';
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
                          color: Theme.of(context).colorScheme.errorContainer,
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
                    const SizedBox(height: 16),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push('/forgot-password');
                        },
                        child: Text(
                          'Забули пароль?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                'Увійти',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
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
