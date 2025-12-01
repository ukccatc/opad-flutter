import 'dart:html' as html;
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/articles_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/files_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../widgets/main_layout.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/files')) return 1;
    if (location.startsWith('/login') || location.startsWith('/stats'))
      return 2;
    return 0;
  }

  /// Get the current browser URL path and query string
  static String _getInitialLocation() {
    try {
      final uri = Uri.parse(html.window.location.href);
      final path = uri.path;
      final query = uri.query;
      final location = query.isNotEmpty ? '$path?$query' : path;
      print('🌐 Initial location from browser: $location');
      print('🌐 Full URL: ${html.window.location.href}');
      return location;
    } catch (e) {
      print('❌ Error getting initial location: $e');
      return '/';
    }
  }

  static final GoRouter router = GoRouter(
    // Use current browser URL as initial location for direct links
    initialLocation: _getInitialLocation(),
    redirect: (context, state) async {
      print('=== Router Redirect Check ===');
      print('Full URI: ${state.uri}');
      print('Path: ${state.uri.path}');
      print('Query params: ${state.uri.queryParameters}');
      print(
        'Location: ${state.uri.path}${state.uri.query.isNotEmpty ? '?${state.uri.query}' : ''}',
      );

      final isLoggedIn = await _authService.isLoggedIn();
      final login = await _authService.getLogin();

      // Allow password reset routes without authentication - MUST return null
      if (state.uri.path == '/reset-password' ||
          state.uri.path == '/forgot-password') {
        print('✅ Password reset route - allowing access (no redirect)');
        return null; // No redirect needed - allow access
      }

      // If user is logged in and tries to access login page, redirect to stats
      if (state.uri.path == '/login' && isLoggedIn && login != null) {
        print('Redirecting logged-in user from /login to /stats');
        return '/stats?login=$login';
      }

      // If user tries to access stats without login, redirect to login
      if (state.uri.path == '/stats' && !isLoggedIn) {
        print('Redirecting unauthenticated user from /stats to /login');
        return '/login';
      }

      // If user is logged in and accessing stats without login param, add it
      if (state.uri.path == '/stats' && isLoggedIn && login != null) {
        if (!state.uri.queryParameters.containsKey('login')) {
          print('Adding login param to /stats');
          return '/stats?login=$login';
        }
      }

      print('No redirect needed');
      return null; // No redirect needed
    },
    errorBuilder: (context, state) {
      print('=== Router Error ===');
      print('Error state: ${state.error}');
      print('Error location: ${state.uri}');
      print('Error path: ${state.uri.path}');

      // If it's a reset-password route with error, still try to show it
      if (state.uri.path == '/reset-password') {
        final email = state.uri.queryParameters['email'] ?? '';
        final token = state.uri.queryParameters['token'] ?? '';
        print('Attempting to show reset password screen despite error');
        return MainLayout(
          selectedIndex: _getSelectedIndex(state.uri.path),
          child: ResetPasswordScreen(email: email, token: token),
        );
      }

      // Default error screen - redirect to home
      print('Redirecting to home due to routing error');
      return MainLayout(selectedIndex: 0, child: const HomeScreen());
    },
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
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) {
          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          // Extract and decode query parameters
          // go_router should auto-decode, but we'll be explicit for safety
          String email = state.uri.queryParameters['email'] ?? '';
          String token = state.uri.queryParameters['token'] ?? '';

          // If email is still encoded (contains %40), decode it manually
          if (email.contains('%')) {
            try {
              email = Uri.decodeComponent(email);
            } catch (e) {
              print('Error decoding email: $e');
            }
          }

          print('=== Reset Password Route Builder ===');
          print('Full URI: ${state.uri}');
          print('Full URI string: ${state.uri.toString()}');
          print('Path: ${state.uri.path}');
          print('Query string: ${state.uri.query}');
          print('Query params map: ${state.uri.queryParameters}');
          print('Email (raw): ${state.uri.queryParameters['email']}');
          print('Email (decoded): $email');
          print('Token: $token');
          print('Email isEmpty: ${email.isEmpty}');
          print('Token isEmpty: ${token.isEmpty}');
          print('Email length: ${email.length}');
          print('Token length: ${token.length}');

          if (email.isEmpty || token.isEmpty) {
            print('⚠️ WARNING: Email or token is empty!');
            print('This will cause the screen to show an error message');
            print('Raw query params: ${state.uri.queryParameters}');
          } else {
            print('✅ Parameters extracted successfully');
          }

          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: ResetPasswordScreen(email: email, token: token),
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
