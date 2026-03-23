import 'package:flutter/material.dart';

import '../logic/l_billing_profile.dart';
import '../utils/k.dart';

/// Billing Profile Screen - Displays user billing information from MySQL
class BillingProfileScreen extends StatefulWidget {
  final String userEmail;

  const BillingProfileScreen({super.key, required this.userEmail});

  @override
  State<BillingProfileScreen> createState() => _BillingProfileScreenState();
}

class _BillingProfileScreenState extends State<BillingProfileScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      K.logicR<BillingProfileLogic>(context).fetchAccount(widget.userEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = K.logicW<BillingProfileLogic>(context);
    final account = logic.account;
    final isLoading = logic.isLoading;
    final error = logic.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль Користувача'), elevation: 0),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Помилка завантаження даних',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      K.logicR<BillingProfileLogic>(context).fetchAccount(widget.userEmail);
                    },
                    child: const Text('Спробувати ще раз'),
                  ),
                ],
              ),
            );
          }

          if (account == null) {
            return const Center(child: Text('Дані не знайдені'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Center(
                                child: Text(
                                  account.fullName.isNotEmpty
                                      ? account.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.fullName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    account.email,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Billing Information
                Text(
                  'Інформація про рахунок',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                // Total Amount Card
                Card(
                  color: account.totalAmount >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Поточний рахунок',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${account.totalAmount} грн',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: account.totalAmount >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Icon(
                              account.totalAmount >= 0
                                  ? Icons.check_circle
                                  : Icons.circle_sharp,
                              color: account.totalAmount >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Union Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Статус члена профспілки',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              account.isUnionMember
                                  ? 'Активний член'
                                  : 'Не член',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: account.isUnionMember
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                        Icon(
                          account.isUnionMember ? Icons.verified : Icons.info,
                          color: account.isUnionMember
                              ? Colors.green
                              : Colors.orange,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User Details
                Text(
                  'Деталі користувача',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'ID користувача',
                          account.id,
                        ),
                        const Divider(),
                        _buildDetailRow(context, 'Email', account.email),
                        const Divider(),
                        _buildDetailRow(context, 'ПІБ', account.fullName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement payment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Функція оплати буде доступна незабаром',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Здійснити платіж'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement download receipt
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Завантаження квитанції...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Завантажити квитанцію'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
