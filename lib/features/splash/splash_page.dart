import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Optional: keep your existing delay/animation duration
      await Future.delayed(const Duration(milliseconds: 1200));

      final session = Supabase.instance.client.auth.currentSession;

      if (!mounted) return;
      if (session != null) {
        // Already authenticated → go to your existing gate at '/'
        // Your AuthLandingGate will route to Alliance/General/Paywall as before.
        context.go('/');
      } else {
        // Not signed in → show public landing
        context.go('/free');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - replace with your actual logo
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Regeneration Global',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Building a sustainable future',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.teal[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Loading indicator
            CircularProgressIndicator(
              color: Colors.teal[800],
            ),
          ],
        ),
      ),
    );
  }
}