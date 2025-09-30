import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../payments/purchases_provider.dart'; // getPurchasesService()

/// Small async gate that decides where to send the user.
class AuthLandingGate extends StatefulWidget {
  const AuthLandingGate({super.key});

  @override
  State<AuthLandingGate> createState() => _AuthLandingGateState();
}

class _AuthLandingGateState extends State<AuthLandingGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;

    if (session == null) {
      context.go('/login');
      return;
    }

    // Check entitlements (mock now, RevenueCat later)
    final svc = getPurchasesService();
    try {
      final ents = await svc.getEntitlements();
      if (!mounted) return;

      if (ents.alliance) {
        context.go('/dashboard/alliance');
      } else if (ents.general) {
        context.go('/dashboard/general');
      } else {
        context.go('/paywall');
      }
    } catch (_) {
      if (!mounted) return;
      // If anything fails, at least go to paywall for a recoverable state.
      context.go('/paywall');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tiny loader while we decide.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
