import 'package:purchases_flutter/purchases_flutter.dart';

/// Initialize RevenueCat with your API key
/// This should be called in main() before the app starts
Future<void> initializeRevenueCat() async {
  try {
    // Platform-specific API keys
    const String apiKey = 'test_wHvETHhAndEDbOsXBdcTffcxhxs';

    final purchasesConfiguration = PurchasesConfiguration(apiKey);

    print('🔧 [RevenueCat] Initializing with API key: $apiKey');
    await Purchases.configure(purchasesConfiguration);

    print('✅ [RevenueCat] Initialization successful');

    // Check if offerings are available
    try {
      final offerings = await Purchases.getOfferings();
      print(
        '✅ [RevenueCat] Offerings available: ${offerings.all.keys.toList()}',
      );
    } catch (e) {
      print(
        '⚠️  [RevenueCat] Warning: Could not fetch offerings during init: $e',
      );
    }
  } catch (e) {
    print('❌ [RevenueCat] Error initializing RevenueCat: $e');
    rethrow;
  }
}
