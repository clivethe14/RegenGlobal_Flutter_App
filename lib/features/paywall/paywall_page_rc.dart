import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../payments/rc_service.dart';
import '../../payments/error_handler.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  bool _loading = false;
  String? _errorMessage;

  Future<void> _purchasePackage(Package package, String planKey) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final rcService = RevenueCatService();

      print('🛒 Starting purchase for package: ${package.identifier}');

      // 1) Purchase through RevenueCat
      final customerInfo = await rcService.purchasePackage(package);

      print(
          '✅ Purchase completed. Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');

      // 2) Verify the entitlement was granted
      final hasEntitlement =
          customerInfo.entitlements.active.containsKey(planKey);

      if (!hasEntitlement) {
        throw Exception('Purchase completed but entitlement not found');
      }

      // 3) Update Supabase profile (profile already exists from trigger, so use update not upsert)
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        print('📝 Updating Supabase profile for user: $uid');
        try {
          await Supabase.instance.client.from('profiles').update({
            'plan': planKey,
            'status': 'active',
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', uid);
          print('✅ Supabase profile updated');
        } catch (e) {
          print('⚠️ Supabase update failed (but purchase succeeded): $e');
          // Don't fail the entire flow - the entitlement is granted in RevenueCat
        }
      }

      // 4) Navigate based on plan
      if (!mounted) return;
      final dashboardRoute = planKey == 'associate'
          ? '/dashboard/associate'
          : planKey == 'alliance'
              ? '/dashboard/alliance'
              : '/dashboard/general';

      print('🚀 Navigating to: $dashboardRoute');
      context.go('/nda?next=${Uri.encodeComponent(dashboardRoute)}');
    } catch (e) {
      print('❌ Purchase error: $e');
      setState(() {
        _errorMessage = PurchaseErrorHandler.handlePurchaseError(e);
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Purchase failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _restore() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Restoring purchases...');
      final rcService = RevenueCatService();
      final customerInfo = await rcService.restorePurchases();

      print(
          '✅ Restore completed. Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');

      // Check what was restored
      final hasAssociate =
          customerInfo.entitlements.active.containsKey('associate');
      final hasAlliance =
          customerInfo.entitlements.active.containsKey('alliance');
      final hasGeneral =
          customerInfo.entitlements.active.containsKey('general');

      if (hasAssociate || hasAlliance || hasGeneral) {
        // Update Supabase
        final uid = Supabase.instance.client.auth.currentUser?.id;
        if (uid != null) {
          final plan = hasAssociate
              ? 'associate'
              : hasAlliance
                  ? 'alliance'
                  : 'general';
          try {
            await Supabase.instance.client.from('profiles').update({
              'plan': plan,
              'status': 'active',
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('user_id', uid);
          } catch (e) {
            print('⚠️ Supabase update failed during restore: $e');
            // Don't fail the restore - entitlement is in RevenueCat
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appropriate dashboard
        final dashboardRoute = hasAssociate
            ? '/dashboard/associate'
            : hasAlliance
                ? '/dashboard/alliance'
                : '/dashboard/general';
        context.go(dashboardRoute);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous purchases found'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      print('❌ Restore error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        actions: [
          IconButton(
            tooltip: 'Restore purchases',
            onPressed: _loading ? null : _restore,
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : FutureBuilder<Offerings>(
              future: RevenueCatService().getOfferings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading plans...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load plans',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final offerings = snapshot.data;
                if (offerings == null || offerings.all.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No plans available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Plans are being configured. Please check back soon.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Try to get Alliance, General, and Associate offerings
                final allianceOffering = offerings.getOffering('Alliance');
                final generalOffering = offerings.getOffering('General');
                final associateOffering = offerings.getOffering('associate');

                print('📦 Offerings loaded:');
                print(
                    '   Alliance: ${allianceOffering?.availablePackages.length ?? 0} packages');
                print(
                    '   General: ${generalOffering?.availablePackages.length ?? 0} packages');
                print(
                    '   Associate: ${associateOffering?.availablePackages.length ?? 0} packages');

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const _Header(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Alliance Section
                    if (allianceOffering != null) ...[
                      _OfferingSection(
                        title: 'Alliance Plans',
                        subtitle: 'For businesses and organizations',
                        offering: allianceOffering,
                        planKey: 'alliance',
                        onPurchase: _purchasePackage,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // General Section
                    if (generalOffering != null) ...[
                      _OfferingSection(
                        title: 'General Plans',
                        subtitle: 'For individual customers',
                        offering: generalOffering,
                        planKey: 'general',
                        onPurchase: _purchasePackage,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Associate Section
                    if (associateOffering != null) ...[
                      _OfferingSection(
                        title: 'Associate Plans',
                        subtitle: 'For partner organizations',
                        offering: associateOffering,
                        planKey: 'associate',
                        onPurchase: _purchasePackage,
                      ),
                    ],

                    if (allianceOffering == null &&
                        generalOffering == null &&
                        associateOffering == null)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No offerings configured yet. Please contact support.',
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 28),
                    const _FinePrint(),
                  ],
                );
              },
            ),
    );
  }
}

class _OfferingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Offering offering;
  final String planKey;
  final Future<void> Function(Package, String) onPurchase;

  const _OfferingSection({
    required this.title,
    required this.subtitle,
    required this.offering,
    required this.planKey,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 16),
        if (offering.availablePackages.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No packages available'),
            ),
          )
        else
          ...offering.availablePackages.map((package) {
            return _PackageCard(
              package: package,
              onPressed: () => onPurchase(package, planKey),
            );
          }),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onPressed;

  const _PackageCard({
    required this.package,
    required this.onPressed,
  });

  String _getPackageDisplayName(String identifier) {
    if (identifier.toLowerCase().contains('annual')) return 'Annual';
    if (identifier.toLowerCase().contains('quarterly') ||
        identifier.toLowerCase().contains('three_month') ||
        identifier == '\$rc_three_month') return 'Quarterly';
    if (identifier.toLowerCase().contains('monthly')) return 'Monthly';
    return identifier;
  }

  String _getBillingPeriod(String identifier) {
    if (identifier.toLowerCase().contains('annual')) return 'Billed annually';
    if (identifier.toLowerCase().contains('quarterly') ||
        identifier.toLowerCase().contains('three_month') ||
        identifier == '\$rc_three_month') return 'Billed every 3 months';
    if (identifier.toLowerCase().contains('monthly')) return 'Billed monthly';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = package.storeProduct;
    final displayName = _getPackageDisplayName(package.identifier);
    final billingPeriod = _getBillingPeriod(package.identifier);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceString,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (billingPeriod.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      billingPeriod,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Subscribe'),
            ),
          ],
        ),
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
        Text('Unlock Full Access', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Choose a plan to continue. You can manage your subscription anytime in the Google Play Store.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _FinePrint extends StatelessWidget {
  const _FinePrint();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.black54,
        );
    return Text(
      'Payments are processed securely through Google Play. '
      'Subscriptions auto-renew until canceled. Terms may apply.',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
