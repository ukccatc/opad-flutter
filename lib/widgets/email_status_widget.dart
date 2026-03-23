import 'package:flutter/material.dart';
import 'package:flutter_opad/logic/l_email.dart';
import 'package:provider/provider.dart';

/// Email Status Widget
/// Displays email sending status and errors
class EmailStatusWidget extends StatelessWidget {
  final VoidCallback? onDismiss;

  const EmailStatusWidget({Key? key, this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailLogic>(
      builder: (context, emailLogic, _) {
        // Show loading
        if (emailLogic.isSending) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sending email...',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          );
        }

        // Show error
        if (emailLogic.lastError != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emailLogic.lastError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    emailLogic.clearError();
                    onDismiss?.call();
                  },
                ),
              ],
            ),
          );
        }

        // Show success
        if (emailLogic.lastOperationSuccess) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emailLogic.lastResponse?.message ??
                        'Email sent successfully',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.green),
                  onPressed: () {
                    emailLogic.clearResponse();
                    onDismiss?.call();
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
