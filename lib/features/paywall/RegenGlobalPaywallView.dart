import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../payments/offerings_provider.dart';

/// RevenueCat Paywall View with custom dismiss handling
class RegenGlobalPaywallView extends ConsumerWidget {
  final VoidCallback onDismiss;

  const RegenGlobalPaywallView({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaywallView(
      onDismiss: onDismiss,
    );
  }
}

/// Standalone Paywall Widget
class StandalonePaywallView extends StatelessWidget {
  const StandalonePaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaywallView(
        onDismiss: () {
          // Handle dismiss
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Paywall wrapper with loading state
class PaywallWithLoading extends ConsumerWidget {
  final VoidCallback onDismiss;

  const PaywallWithLoading({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOfferingAsync = ref.watch(currentOfferingProvider);

    return currentOfferingAsync.when(
      data: (_) => PaywallView(
        onDismiss: onDismiss,
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading paywall'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onDismiss,
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
