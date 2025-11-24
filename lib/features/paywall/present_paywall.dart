import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Present the RevenueCat paywall UI
/// This shows the configured paywall for purchasing
Future<PaywallResult> presentPaywall({String? displayCloseButton}) async {
  try {
    final paywallResult = await RevenueCatUI.presentPaywall();
    print('Paywall dismissed with result: ${paywallResult.toString()}');
    return paywallResult;
  } catch (e) {
    print('Error presenting paywall: $e');
    rethrow;
  }
}

/// Present customer center for managing subscriptions
/// Allows users to manage their subscriptions and view their account
Future<void> presentCustomerCenter() async {
  try {
    await RevenueCatUI.presentCustomerCenter();
    print('Customer center presented');
  } catch (e) {
    print('Error presenting customer center: $e');
    rethrow;
  }
}
