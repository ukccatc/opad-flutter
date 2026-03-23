import 'package:flutter/material.dart';
import 'package:flutter_opad/logic/l_password_reset.dart';
import 'package:flutter_opad/utils/k.dart';
import 'package:provider/provider.dart';

/// Password Reset Screen
/// Allows users to reset their password with a valid token
class PasswordResetScreen extends StatefulWidget {
  final String? token;

  const PasswordResetScreen({Key? key, this.token}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Validate token on init
    if (widget.token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _validateToken();
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final resetLogic = context.read<PasswordResetLogic>();
    final valid = await resetLogic.validateToken(widget.token!);

    if (!valid && mounted) {
      K.showSnackBar('Invalid or expired reset link', isError: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Future<void> _handleResetPassword() async {
    final resetLogic = context.read<PasswordResetLogic>();

    final success = await resetLogic.resetPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (mounted) {
      if (success) {
        K.showSnackBar('Password reset successfully');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        K.showSnackBar(
          resetLogic.error ?? 'Failed to reset password',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: Consumer<PasswordResetLogic>(
        builder: (context, resetLogic, _) {
          // Invalid token
          if (!resetLogic.tokenValid &&
              widget.token != null &&
              !resetLogic.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Invalid or Expired Link',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This password reset link has expired or is invalid.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // Loading
          if (resetLogic.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Reset form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Create New Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${resetLogic.email ?? 'Loading...'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Error message
                if (resetLogic.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            resetLogic.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (resetLogic.error != null) const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  enabled: !resetLogic.isLoading,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !resetLogic.isLoading,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm new password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password Requirements:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _PasswordRequirement(
                        text: 'At least 6 characters',
                        met: _passwordController.text.length >= 6,
                      ),
                      _PasswordRequirement(
                        text: 'Passwords match',
                        met:
                            _passwordController.text ==
                                _confirmPasswordController.text &&
                            _passwordController.text.isNotEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Reset button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: resetLogic.isLoading
                        ? null
                        : _handleResetPassword,
                    child: resetLogic.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reset Password'),
                  ),
                ),
                const SizedBox(height: 16),

                // Back button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Password Requirement Indicator
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool met;

  const _PasswordRequirement({required this.text, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          color: met ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: met ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
