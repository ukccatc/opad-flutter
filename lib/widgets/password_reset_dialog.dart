import 'package:flutter/material.dart';
import 'package:flutter_opad/config/email_config.dart';
import 'package:flutter_opad/logic/l_email.dart';
import 'package:flutter_opad/utils/k.dart';
import 'package:provider/provider.dart';

/// Password Reset Dialog
/// Dialog for requesting password reset with email sending
class PasswordResetDialog extends StatefulWidget {
  final String? initialEmail;
  final VoidCallback? onSuccess;

  const PasswordResetDialog({Key? key, this.initialEmail, this.onSuccess})
    : super(key: key);

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    // Validate inputs
    if (email.isEmpty) {
      K.showSnackBar('Please enter your email', isError: true);
      return;
    }

    if (!EmailConfig.isValidEmail(email)) {
      K.showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    if (name.isEmpty) {
      K.showSnackBar('Please enter your name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final emailLogic = context.read<EmailLogic>();

      // Generate a token (in production, this should come from backend)
      final token = DateTime.now().millisecondsSinceEpoch.toString();

      // Send password reset email
      final success = await emailLogic.sendPasswordResetEmail(
        email: email,
        name: name,
        token: token,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          K.showSnackBar('Password reset email sent successfully');
          widget.onSuccess?.call();
          Navigator.of(context).pop();
        } else {
          K.showSnackBar(
            emailLogic.lastError ?? 'Failed to send password reset email',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        K.showSnackBar('Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email and name to receive a password reset link.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<EmailLogic>(
              builder: (context, emailLogic, _) {
                if (emailLogic.lastError != null) {
                  return Container(
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
                            emailLogic.lastError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePasswordReset,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Reset Link'),
        ),
      ],
    );
  }
}
