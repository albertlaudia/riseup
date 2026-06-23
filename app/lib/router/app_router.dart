import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/lesson_detail_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quotes_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/signin_screen.dart';
import '../widgets/shell_scaffold.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth flow (no shell)
      GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),

      // Main shell
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(path: '/',         builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/library',  builder: (_, __) => const LibraryScreen()),
          GoRoute(path: '/quotes',   builder: (_, __) => const QuotesScreen()),
          GoRoute(path: '/profile',  builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Detail screens (pushed on top of shell)
      GoRoute(
        path: '/library/:slug',
        builder: (_, state) => LessonDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(path: '/paywall',  builder: (_, __) => const PaywallScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/about',    builder: (_, __) => const AboutScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text("Couldn't find that page.", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(state.uri.toString(), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/'),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
