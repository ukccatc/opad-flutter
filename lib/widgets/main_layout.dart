import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'logo_widget.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const MainLayout({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/articles');
        break;
      case 2:
        context.go('/files');
        break;
      case 3:
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
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onDestinationSelected(index, context),
              labelType: MediaQuery.of(context).size.width >= 800 
                  ? NavigationRailLabelType.none 
                  : NavigationRailLabelType.all,
              extended: MediaQuery.of(context).size.width >= 800,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined, size: 28),
                  selectedIcon: const Icon(Icons.home_rounded, size: 28),
                  label: const Text('Головна'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.article_outlined, size: 28),
                  selectedIcon: const Icon(Icons.article_rounded, size: 28),
                  label: const Text('Статті'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.folder_outlined, size: 28),
                  selectedIcon: const Icon(Icons.folder_rounded, size: 28),
                  label: const Text('Файли'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline, size: 28),
                  selectedIcon: const Icon(Icons.person_rounded, size: 28),
                  label: const Text('Статистика'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: child,
            ),
          ],
        ),
      );
    } else {
      // Drawer for narrow screens (mobile/tablet)
      return Scaffold(
        drawer: _buildDrawer(context),
        body: child,
      );
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
                  const LogoWidget(
                    size: 40,
                  ),
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
                    leading: Icon(
                      selectedIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color: selectedIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 28, // Larger icons
                    ),
                    title: Text(
                      'Головна',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18, // Larger text
                            fontWeight: selectedIndex == 0 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                    ),
                    selected: selectedIndex == 0,
                    onTap: () {
                      context.go('/');
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      selectedIndex == 1
                          ? Icons.article_rounded
                          : Icons.article_outlined,
                      color: selectedIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 28, // Larger icons
                    ),
                    title: Text(
                      'Статті',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18, // Larger text
                            fontWeight: selectedIndex == 1 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                    ),
                    selected: selectedIndex == 1,
                    onTap: () {
                      context.go('/articles');
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      selectedIndex == 2
                          ? Icons.folder_rounded
                          : Icons.folder_outlined,
                      color: selectedIndex == 2
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 28, // Larger icons
                    ),
                    title: Text(
                      'Файли',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18, // Larger text
                            fontWeight: selectedIndex == 2 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                    ),
                    selected: selectedIndex == 2,
                    onTap: () {
                      context.go('/files');
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      selectedIndex == 3
                          ? Icons.person_rounded
                          : Icons.person_outline,
                      color: selectedIndex == 3
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 28, // Larger icons
                    ),
                    title: Text(
                      'Статистика',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18, // Larger text
                            fontWeight: selectedIndex == 3 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                    ),
                    selected: selectedIndex == 3,
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

