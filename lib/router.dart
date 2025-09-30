import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features
import 'features/dashboard/dashboard_page.dart';
import 'features/dashboard/alliance_dashboard_page.dart';
import 'features/forms/dynamic_form_page.dart';
import 'features/links/web_link_page.dart';
import 'features/lists/item_list_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/paywall/paywall_page.dart';
import 'features/auth/auth_landing_gate.dart';
import 'features/splash/splash_page.dart';
import 'features/auth/nda_page.dart';


import 'dev/dev_tools.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final location = state.fullPath;

      // Allow splash page to show first
      if (location == '/splash') return null;

      // If not signed in, redirect to login (except for signup page)
      if (session == null) {
        if (location == '/login' || location == '/signup') return null;
        return '/login';
      }

      // User is signed in - prevent access to auth pages
      if (location == '/login' || location == '/signup') {
        return '/'; // This will trigger the AuthLandingGate
      }

      // Allow paywall access for signed-in users
      if (location == '/paywall') return null;

      // Allow all other routes - let AuthLandingGate handle the logic
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: '/',
        builder: (context, state) => const AuthLandingGate(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallPage(),
      ),

      GoRoute(
        path: '/dashboard/general',
        builder: (context, state) => const DashboardPage(title: 'General Dashboard'),
      ),

      GoRoute(
        path: '/dashboard/alliance',
        builder: (context, state) => const AllianceDashboardPage(),
      ),

      GoRoute(
        path: '/form/:formId',
        name: 'dynamicForm',
        builder: (context, state) {
          final formId = state.pathParameters['formId']!;
          final initialValues = state.extra as Map<String, dynamic>?;
          return DynamicFormPage(formId: formId, initialValues: initialValues);
        },
      ),

      GoRoute(
        path: '/link',
        name: 'webLink',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? 'https://example.com';
          return WebLinkPage(url: url);
        },
      ),

      GoRoute(
        path: '/list/:listId',
        name: 'itemList',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return ItemListPage(listId: listId);
        },
      ),
      GoRoute(
        path: '/nda',
        builder: (context, state) {
          final next = state.uri.queryParameters['next'] ?? '/';
          return NdaPage(nextRoute: next);
        },
      ),

    ],
  );
});