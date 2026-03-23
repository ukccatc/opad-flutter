// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

import '../screens/s_article_detail.dart';
import '../screens/s_articles.dart';
import '../screens/s_files.dart';
import '../screens/s_forgot_password.dart';
import '../screens/s_home.dart';
import '../screens/s_login.dart';
import '../screens/s_reset_password.dart';
import '../screens/s_stats.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import '../widgets/w_main_layout.dart';

class AppRouter {
  static final AuthService _authService = AuthService();

  static int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/files')) return 1;
    if (location.startsWith('/login') || location.startsWith('/stats')) {
      return 2;
    }
    return 0;
  }

  /// Get the current browser URL path and query string
  static String _getInitialLocation() {
    if (!kIsWeb) return '/';
    try {
      // ignore: undefined_prefixed_name
      final href = html.window.location.href;
      final uri = Uri.parse(href);
      final path = uri.path;
      final query = uri.query;
      final location = query.isNotEmpty ? '$path?$query' : path;
      Logger.info('🌐 Initial location from browser: $location');
      Logger.info('🌐 Full URL: $href');
      return location;
    } catch (e) {
      Logger.error('❌ Error getting initial location', e);
      return '/';
    }
  }

  static final GoRouter router = GoRouter(
    // Use current browser URL as initial location for direct links
    initialLocation: _getInitialLocation(),
    redirect: (context, state) async {
      Logger.info('=== Router Redirect Check ===');
      Logger.info('Full URI: ${state.uri}');
      Logger.info('Path: ${state.uri.path}');
      Logger.info('Query params: ${state.uri.queryParameters}');
      Logger.info(
        'Location: ${state.uri.path}${state.uri.query.isNotEmpty ? '?${state.uri.query}' : ''}',
      );

      final isLoggedIn = await _authService.isLoggedIn();
      final login = await _authService.getLogin();

      // Allow password reset routes without authentication - MUST return null
      if (state.uri.path == '/reset-password' ||
          state.uri.path == '/forgot-password') {
        Logger.info('✅ Password reset route - allowing access (no redirect)');
        return null; // No redirect needed - allow access
      }

      // If user is logged in and tries to access login page, redirect to stats
      if (state.uri.path == '/login' && isLoggedIn && login != null) {
        Logger.info('Redirecting logged-in user from /login to /stats');
        return '/stats?login=$login';
      }

      // If user tries to access stats without login, redirect to login
      if (state.uri.path == '/stats' && !isLoggedIn) {
        Logger.info('Redirecting unauthenticated user from /stats to /login');
        return '/login';
      }

      // If user is logged in and accessing stats without login param, add it
      if (state.uri.path == '/stats' && isLoggedIn && login != null) {
        if (!state.uri.queryParameters.containsKey('login')) {
          Logger.info('Adding login param to /stats');
          return '/stats?login=$login';
        }
      }

      Logger.info('No redirect needed');
      return null; // No redirect needed
    },
    errorBuilder: (context, state) {
      Logger.info('=== Router Error ===');
      Logger.info('Error state: ${state.error}');
      Logger.info('Error location: ${state.uri}');
      Logger.info('Error path: ${state.uri.path}');

      // If it's a reset-password route with error, still try to show it
      if (state.uri.path == '/reset-password') {
        final token = state.uri.queryParameters['token'] ?? '';
        Logger.info('Attempting to show reset password screen despite error');
        return MainLayout(
          selectedIndex: _getSelectedIndex(state.uri.path),
          child: ResetPasswordScreen(token: token),
        );
      }

      // Default error screen - redirect to home
      Logger.info('Redirecting to home due to routing error');
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
          // Extract token from query parameters
          final token = state.uri.queryParameters['token'] ?? '';

          Logger.info('=== Reset Password Route Builder ===');
          Logger.info('Full URI: ${state.uri}');
          Logger.info('Path: ${state.uri.path}');
          Logger.info('Query string: ${state.uri.query}');
          Logger.info('Token: $token');
          Logger.info('Token isEmpty: ${token.isEmpty}');
          Logger.info('Token length: ${token.length}');

          if (token.isEmpty) {
            Logger.warning('⚠️ WARNING: Token is empty!');
            Logger.warning(
              'This will cause the screen to show an error message',
            );
          } else {
            Logger.info('✅ Token extracted successfully');
          }

          return MainLayout(
            selectedIndex: _getSelectedIndex(state.uri.path),
            child: ResetPasswordScreen(token: token),
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
