import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/articles_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/files_screen.dart';
import '../widgets/main_layout.dart';

class AppRouter {
  static int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/articles')) return 1;
    if (location.startsWith('/files')) return 2;
    if (location.startsWith('/login') || location.startsWith('/stats')) return 3;
    return 0;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: const HomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/articles',
        name: 'articles',
        builder: (context, state) {
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: const ArticlesScreen(),
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            name: 'article-detail',
            builder: (context, state) {
              final articleId = int.parse(state.pathParameters['id']!);
              return MainLayout(
                selectedIndex: _getSelectedIndex(state.uri.path),
                child: ArticleDetailScreen(articleId: articleId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/files',
        name: 'files',
        builder: (context, state) {
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: const FilesScreen(),
          );
        },
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) {
          final login = state.uri.queryParameters['login'] ?? '';
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: StatsScreen(login: login),
          );
        },
      ),
    ],
  );
}

