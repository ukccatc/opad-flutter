import 'package:flutter/material.dart';
import 'package:flutter_opad/widgets/w_logo.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const MainLayout({super.key, required this.child, this.selectedIndex = 0});

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/files');
        break;
      case 2:
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    if (isWideScreen) {
      // Navigation Rail for wide screens (web desktop)
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: null,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(index, context),
              labelType: MediaQuery.of(context).size.width >= 800
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              extended: MediaQuery.of(context).size.width >= 800,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined, size: 28),
                  label: const Text('Головна'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.folder_outlined, size: 28),
                  label: const Text('Файли'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline, size: 28),
                  label: const Text('Статистика'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      // Drawer for narrow screens (mobile/tablet)
      return Scaffold(drawer: _buildDrawer(context), body: child);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  const LogoWidget(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'OPAD',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined, size: 28),
                    title: Text(
                      'Головна',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      context.go('/');
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined, size: 28),
                    title: Text(
                      'Файли',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      context.go('/files');
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline, size: 28),
                    title: Text(
                      'Статистика',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      context.go('/login');
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
