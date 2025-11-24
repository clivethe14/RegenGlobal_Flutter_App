// lib/features/paywall/paywall_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../payments/purchases_provider.dart'; // <- same folder as this file
// If your file is elsewhere, adjust e.g. '../payments/purchases_provider.dart'

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  Future<void> _onSelectPlan(
    BuildContext context,
    WidgetRef ref, {
    required String productId, // RevenueCat package identifier (billing)
    required String planKey, // Value you store in Supabase profiles.plan
  }) async {
    final svc = ref.read(purchaseServiceProvider);

    // 1) Trigger the purchase flow (RevenueCat / Mock)
    final ok = await svc.purchasePlan(productId);
    if (!ok) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase was not completed')),
      );
      return;
    }

    // 2) Update Supabase profile with the chosen plan
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not signed in')),
      );
      return;
    }

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'plan': planKey}).eq('user_id', uid);

      // 3) Proceed to NDA; route to dashboard based on planKey
      if (!context.mounted) return;
      final dashboardRoute =
          planKey == 'alliance' ? '/dashboard/alliance' : '/dashboard/general';
      context.go('/nda?next=${Uri.encodeComponent(dashboardRoute)}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update plan: $e')),
      );
    }
  }

  Future<void> _restore(WidgetRef ref, BuildContext context) async {
    final svc = ref.read(purchaseServiceProvider);
    try {
      await svc.restorePurchases();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored (if available)')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adjust text/labels to match your previous UI if needed.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your plan'),
        actions: [
          IconButton(
            tooltip: 'Restore purchases',
            onPressed: () => _restore(ref, context),
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(),
          const SizedBox(height: 16),

          // ========== ALLIANCE SECTION ==========
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Alliance Plans',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _PlanCard(
            title: 'Alliance (Annual)',
            subtitle: 'Best value for businesses',
            priceLine: 'Billed annually',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'alliance_annual',
              planKey: 'alliance',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Alliance (Quarterly)',
            subtitle: 'Quarterly commitment',
            priceLine: 'Billed every 3 months',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'alliance_quarterly',
              planKey: 'alliance',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Alliance (Monthly)',
            subtitle: 'Month-to-month flexibility',
            priceLine: 'Billed monthly',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'alliance_monthly',
              planKey: 'alliance',
            ),
          ),

          const SizedBox(height: 24),

          // ========== GENERAL SECTION ==========
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'General Plans',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _PlanCard(
            title: 'General (Annual)',
            subtitle: 'For individual customers',
            priceLine: 'Billed annually',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'general_annual',
              planKey: 'general',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'General (Quarterly)',
            subtitle: 'Quarterly commitment',
            priceLine: 'Billed every 3 months',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'general_quarterly',
              planKey: 'general',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'General (Monthly)',
            subtitle: 'Month-to-month flexibility',
            priceLine: 'Billed monthly',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'general_monthly',
              planKey: 'general',
            ),
          ),

          const SizedBox(height: 24),

          // ========== ASSOCIATE SECTION ==========
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Associate Plans',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _PlanCard(
            title: 'Associate (Annual)',
            subtitle: 'For partner organizations',
            priceLine: 'Billed annually',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'associate_annual',
              planKey: 'associate',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Associate (Quarterly)',
            subtitle: 'Quarterly commitment',
            priceLine: 'Billed every 3 months',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'associate_quarterly',
              planKey: 'associate',
            ),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Associate (Monthly)',
            subtitle: 'Month-to-month flexibility',
            priceLine: 'Billed monthly',
            ctaText: 'Continue',
            onPressed: () => _onSelectPlan(
              context,
              ref,
              productId: 'associate_monthly',
              planKey: 'associate',
            ),
          ),

          const SizedBox(height: 28),
          const _FinePrint(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Unlock full access', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Choose a plan to continue. You can manage your subscription anytime in the app store.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceLine;
  final String ctaText;
  final VoidCallback onPressed;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.priceLine,
    required this.ctaText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(priceLine,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(ctaText),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinePrint extends StatelessWidget {
  const _FinePrint();

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54);
    return Text(
      'Payments are processed securely through Google Play. '
      'Subscriptions auto-renew until canceled. Terms may apply.',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
