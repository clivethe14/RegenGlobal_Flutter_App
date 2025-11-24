import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../payments/offerings_provider.dart';
import '../../payments/rc_service.dart';
import '../../payments/check_entitlement.dart';
import '../../payments/error_handler.dart';
import 'present_paywall.dart';

/// Complete example of RevenueCat integration
/// Shows all major features: products, purchases, entitlements, customer center
class SubscriptionExamplePage extends ConsumerWidget {
  const SubscriptionExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProAsync = ref.watch(hasProEntitlementProvider);
    final subscriberInfoAsync = ref.watch(subscriberInfoProvider);
    final currentOfferingAsync = ref.watch(currentOfferingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Section
            _StatusSection(hasProAsync: hasProAsync),

            const Divider(),

            // Subscriber Info Section
            _SubscriberInfoSection(subscriberInfoAsync: subscriberInfoAsync),

            const Divider(),

            // Products Section
            _ProductsSection(
              currentOfferingAsync: currentOfferingAsync,
              ref: ref,
            ),

            const Divider(),

            // Actions Section
            _ActionsSection(),
          ],
        ),
      ),
    );
  }
}

/// Shows current subscription status
class _StatusSection extends StatelessWidget {
  final AsyncValue<bool> hasProAsync;

  const _StatusSection({required this.hasProAsync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          hasProAsync.when(
            data: (hasPro) => _StatusCard(
              hasPro: hasPro,
              status: hasPro ? 'Pro Member' : 'Free User',
              icon: hasPro ? Icons.verified : Icons.lock_outline,
              color: hasPro ? Colors.green : Colors.grey,
            ),
            loading: () => const _LoadingCard(),
            error: (err, st) => _ErrorCard(error: err.toString()),
          ),
        ],
      ),
    );
  }
}

/// Shows detailed subscriber information
class _SubscriberInfoSection extends StatelessWidget {
  final AsyncValue<SubscriberInfo?> subscriberInfoAsync;

  const _SubscriberInfoSection({required this.subscriberInfoAsync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          subscriberInfoAsync.when(
            data: (info) {
              if (info == null) {
                return const Text('No subscription data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoTile(
                    label: 'Active Entitlements',
                    value: info.activeEntitlements.isEmpty
                        ? 'None'
                        : info.activeEntitlements.join(', '),
                  ),
                  if (info.proExpirationDate != null) ...[
                    const SizedBox(height: 8),
                    _InfoTile(
                      label: 'Pro Expires',
                      value: _formatDate(info.proExpirationDate),
                    ),
                  ],
                  if (info.isProExpired) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Your Pro subscription has expired',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const _LoadingCard(),
            error: (err, st) => _ErrorCard(error: err.toString()),
          ),
        ],
      ),
    );
  }
}

/// Shows available products for purchase
class _ProductsSection extends ConsumerWidget {
  final AsyncValue<Offering?> currentOfferingAsync;
  final WidgetRef ref;

  const _ProductsSection({
    required this.currentOfferingAsync,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          currentOfferingAsync.when(
            data: (offering) {
              if (offering == null || offering.availablePackages.isEmpty) {
                return const Text('No plans available');
              }

              return Column(
                children: offering.availablePackages.map((package) {
                  return _PackageCard(package: package);
                }).toList(),
              );
            },
            loading: () => const _LoadingCard(),
            error: (err, st) => _ErrorCard(error: err.toString()),
          ),
        ],
      ),
    );
  }
}

/// Shows action buttons
class _ActionsSection extends ConsumerWidget {
  const _ActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _presentPaywall(context),
                  icon: const Icon(Icons.storefront),
                  label: const Text('Present Paywall'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openCustomerCenter(context),
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Manage Subscription'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _restorePurchases(context, ref),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Purchases'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _presentPaywall(BuildContext context) async {
    try {
      await presentPaywall();
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, PurchaseErrorHandler.handlePurchaseError(e));
      }
    }
  }

  Future<void> _openCustomerCenter(BuildContext context) async {
    try {
      await presentCustomerCenter();
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _restorePurchases(BuildContext context, WidgetRef ref) {
    try {
      syncPurchases().then((_) {
        // Invalidate so providers refetch latest data
        ref.invalidate(hasProEntitlementProvider);
        ref.invalidate(subscriberInfoProvider);
      });
      if (context.mounted) {
        _showSnackBar(context, 'Purchases restored successfully');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, PurchaseErrorHandler.handlePurchaseError(e));
      }
    }
  }
}

/// UI Components

class _StatusCard extends StatelessWidget {
  final bool hasPro;
  final String status;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.hasPro,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PackageCard extends ConsumerWidget {
  final Package package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = package.identifier;
    final price = package.packageType.toString().split('.').last;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _purchase(context, ref),
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }

  void _purchase(BuildContext context, WidgetRef ref) async {
    try {
      final success = await purchasePackage(package);
      if (success) {
        // Invalidate providers so they refetch from RevenueCatService
        ref.invalidate(hasProEntitlementProvider);
        ref.invalidate(subscriberInfoProvider);
        // Optionally await freshly computed values to ensure UI updates
        await ref.read(hasProEntitlementProvider.future);
        await ref.read(subscriberInfoProvider.future);
        if (context.mounted) {
          _showSnackBar(context, 'Purchase successful!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, PurchaseErrorHandler.handlePurchaseError(e));
      }
    }
  }
}

// Helper functions

String _formatDate(dynamic date) {
  if (date is DateTime) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  return 'Unknown';
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
