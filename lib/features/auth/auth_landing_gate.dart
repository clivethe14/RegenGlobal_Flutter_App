import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../payments/rc_service.dart';

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
      print('🔒 No session - redirecting to login');
      context.go('/login');
      return;
    }

    print('✅ Session found - checking entitlements');

    try {
      final rcService = RevenueCatService();

      // Ensure RevenueCat is logged in with current Supabase user
      final userId = session.user.id;
      print('🔐 Ensuring RevenueCat is logged in as: $userId');
      await rcService.logIn(userId);

      // Now check entitlements
      final hasAlliance = await rcService.hasAllianceEntitlement();
      final hasGeneral = await rcService.hasGeneralEntitlement();
      final hasAssociate = await rcService.hasAssociateEntitlement();

      print('🎫 Entitlements check:');
      print('   Alliance: $hasAlliance');
      print('   General: $hasGeneral');
      print('   Associate: $hasAssociate');

      if (!mounted) return;

      if (hasAssociate) {
        print('🚀 Redirecting to Associate dashboard');
        context.go('/dashboard/associate');
      } else if (hasAlliance) {
        print('🚀 Redirecting to Alliance dashboard');
        context.go('/dashboard/alliance');
      } else if (hasGeneral) {
        print('🚀 Redirecting to General dashboard');
        context.go('/dashboard/general');
      } else {
        print('⚠️  No active entitlements - redirecting to paywall');
        context.go('/paywall');
      }
    } catch (e) {
      print('❌ Error checking entitlements: $e');
      if (!mounted) return;
      context.go('/paywall');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tiny loader while we decide
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking subscription...'),
          ],
        ),
      ),
    );
  }
}
