import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features
import 'features/dashboard/dashboard_page.dart';
import 'features/dashboard/alliance_dashboard_page.dart';
import 'features/dashboard/associate_dashboard_page.dart';
import 'features/forms/dynamic_form_page_wrapper.dart';
import 'features/links/web_link_page.dart';
import 'features/lists/item_list_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/paywall/paywall_page_rc.dart';
import 'features/auth/auth_landing_gate.dart';
import 'features/splash/splash_page.dart';
import 'features/auth/nda_page.dart';
import 'features/dashboard/free_dashboard_page.dart';
import 'features/paywall/media_kit_page.dart';
import 'features/programs/programs_page.dart';

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
      final location = state.uri.toString();
      final session = Supabase.instance.client.auth.currentSession;

      // Always allow splash and free pages (public)
      if (location == '/splash' || location == '/free') return null;

      // If not signed in, allow login and signup, otherwise send to login
      if (session == null) {
        final isPublic = location == '/splash' ||
            location == '/free' ||
            location == '/signup' ||
            location.startsWith('/link') ||
            location.startsWith('/list/');

        if (isPublic) return null;
        return '/login';
      }

      // If signed in, let your normal flow continue
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/free',
        builder: (context, state) => const FreeDashboardPage(),
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
        builder: (context, state) =>
            const DashboardPage(title: 'General Dashboard'),
      ),
      GoRoute(
        path: '/dashboard/alliance',
        builder: (context, state) => const AllianceDashboardPage(),
      ),
      GoRoute(
        path: '/dashboard/associate',
        builder: (context, state) => const AssociateDashboardPage(),
      ),
      GoRoute(
        path: '/media-kit',
        builder: (context, state) => const MediaKitPage(),
      ),
      GoRoute(
        path: '/programs',
        builder: (context, state) => const ProgramsPage(),
      ),
      GoRoute(
        path: '/form/:formId',
        name: 'dynamicForm',
        builder: (context, state) {
          final formId = state.pathParameters['formId']!;
          final initialValues = state.extra as Map<String, dynamic>?;
          return DynamicFormPageWrapper(
              formId: formId, initialValues: initialValues);
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
