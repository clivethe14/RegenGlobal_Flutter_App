# RevenueCat Integration Guide for Regen Global

## Overview
This guide documents the complete RevenueCat SDK integration for your Regen Global Flutter app with subscription management for the "Regen Global Pro" entitlement.

---

## Setup Complete ✓

### 1. **Packages Already Installed**
Your `pubspec.yaml` already contains:
```yaml
purchases_flutter: ^9.9.6
purchases_ui_flutter: ^9.9.6
```

### 2. **API Configuration**
- **API Key**: `test_wHvETHhAndEDbOsXBdcTffcxhxs` (Test key - replace with production key)
- **Entitlement**: `Regen Global Pro`
- **Products**: `monthly`, `yearly`, `three_month`

---

## Architecture Overview

### Core Files Created

#### 1. **`lib/payments/initialize.dart`**
Initializes RevenueCat with your API key. Called in `main()` before app startup.

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initializeRevenueCat() async {
  try {
    const String apiKey = 'test_wHvETHhAndEDbOsXBdcTffcxhxs';
    final purchasesConfiguration = PurchasesConfiguration(apiKey);
    await Purchases.configure(purchasesConfiguration);
    print('RevenueCat initialized successfully');
  } catch (e) {
    print('Error initializing RevenueCat: $e');
    rethrow;
  }
}
```

#### 2. **`lib/payments/rc_service.dart`** (Service Layer)
Singleton service handling all RevenueCat operations:

**Key Methods:**
- `getEntitlements()` - Get active entitlements
- `hasProEntitlement()` - Check for "Regen Global Pro"
- `getCustomerInfo()` - Retrieve customer information
- `getOfferings()` - Fetch available subscription products
- `purchasePackage(Package)` - Process purchase
- `restorePurchases()` - Restore previous purchases
- `logIn(userId)` - Log in user for cross-device sync
- `logOut()` - Log out user

**SubscriberInfo Model:**
```dart
class SubscriberInfo {
  final List<String> activeEntitlements;
  final dynamic proExpirationDate;
  
  bool get isPro => activeEntitlements.contains('Regen Global Pro');
  bool get isProExpired { /* check expiration */ }
}
```

#### 3. **`lib/payments/check_entitlement.dart`**
Convenience functions for common operations:

```dart
// Check if user has Pro entitlement
Future<bool> checkProEntitlement() async { ... }

// Get detailed subscriber info
Future<SubscriberInfo> getSubscriberInfo() async { ... }

// Sync purchases
Future<void> syncPurchases() async { ... }
```

#### 4. **`lib/payments/offerings_provider.dart`** (Riverpod Providers)
Manages offerings and product data with reactive state:

**Available Providers:**
```dart
final offeringsProvider = FutureProvider<Offerings?>(...);
final currentOfferingProvider = FutureProvider<Offering?>(...);
final customerInfoProvider = FutureProvider<CustomerInfo?>(...);
final subscriberInfoProvider = FutureProvider<SubscriberInfo?>(...);
final activeEntitlementsProvider = FutureProvider<List<String>>(...);
final hasProEntitlementProvider = FutureProvider<bool>(...);
```

**Helper Functions:**
```dart
Future<Package?> getMonthlyPackage();
Future<Package?> getYearlyPackage();
Future<Package?> getThreeMonthPackage();
Future<bool> purchasePackage(Package package);
```

#### 5. **`lib/payments/error_handler.dart`**
Comprehensive error handling:

```dart
class PurchaseErrorHandler {
  static String getErrorMessage(dynamic error);
  static bool isCancelledError(dynamic error);
  static bool isNetworkError(dynamic error);
  static String handlePurchaseError(dynamic error);
}

class PurchaseResult<T> {
  final bool success;
  final T? data;
  final String? error;
}
```

#### 6. **Paywall Components**

**`lib/features/paywall/present_paywall.dart`**
```dart
Future<PaywallResult> presentPaywall() async { ... }
Future<void> presentCustomerCenter() async { ... }
```

**`lib/features/paywall/RegenGlobalPaywallView.dart`**
- `RegenGlobalPaywallView` - Custom paywall wrapper
- `StandalonePaywallView` - Full-screen paywall
- `PaywallWithLoading` - Paywall with loading state

---

## Usage Examples

### 1. **Check Subscription Status**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payments/offerings_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProAsync = ref.watch(hasProEntitlementProvider);
    
    return hasProAsync.when(
      data: (hasPro) => Text(hasPro ? 'Pro User' : 'Free User'),
      loading: () => CircularProgressIndicator(),
      error: (err, st) => Text('Error: $err'),
    );
  }
}
```

### 2. **Display Paywall**
```dart
import 'features/paywall/present_paywall.dart';

void showPaywall() async {
  try {
    final result = await presentPaywall();
    print('Paywall result: $result');
  } catch (e) {
    print('Error: $e');
  }
}
```

### 3. **Purchase a Subscription**
```dart
import 'payments/offerings_provider.dart';
import 'payments/error_handler.dart';

void purchaseMonthly() async {
  try {
    final monthlyPackage = await getMonthlyPackage();
    if (monthlyPackage != null) {
      final success = await purchasePackage(monthlyPackage);
      if (success) {
        print('Purchase successful!');
      }
    }
  } catch (e) {
    final errorMsg = PurchaseErrorHandler.handlePurchaseError(e);
    print('Purchase failed: $errorMsg');
  }
}
```

### 4. **Get Subscriber Info**
```dart
import 'payments/check_entitlement.dart';

void checkSubscription() async {
  try {
    final subscriberInfo = await getSubscriberInfo();
    print('Is Pro: ${subscriberInfo.isPro}');
    print('Expiration: ${subscriberInfo.proExpirationDate}');
    print('All Entitlements: ${subscriberInfo.activeEntitlements}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### 5. **Customer Center (Manage Subscriptions)**
```dart
import 'features/paywall/present_paywall.dart';

void openCustomerCenter() async {
  try {
    await presentCustomerCenter();
  } catch (e) {
    print('Error opening customer center: $e');
  }
}
```

### 6. **Restore Purchases**
```dart
import 'payments/check_entitlement.dart';

void restorePurchases() async {
  try {
    await syncPurchases();
    print('Purchases restored successfully');
  } catch (e) {
    print('Error restoring purchases: $e');
  }
}
```

---

## Configuration: RevenueCat Dashboard

### 1. **Create Entitlements**
In RevenueCat dashboard:
1. Go to **Entitlements**
2. Create: `Regen Global Pro`

### 2. **Create Products**
Create these products in RevenueCat:
- **monthly**: Monthly subscription
- **yearly**: Annual subscription  
- **three_month**: 3-month subscription

### 3. **Create Offering**
1. Go to **Offerings**
2. Create default offering with all 3 products
3. Link products to `Regen Global Pro` entitlement

### 4. **Configure Paywall**
1. Use RevenueCat's Paywall Designer
2. Select your offering
3. Design your paywall UI
4. RevenueCat will serve it via `RevenueCatUI.presentPaywall()`

---

## Best Practices

### 1. **Initialization**
✓ Always initialize RevenueCat in `main()` before running the app
✓ Use try-catch for initialization errors

### 2. **Error Handling**
```dart
try {
  // RevenueCat operation
} catch (e) {
  final msg = PurchaseErrorHandler.handlePurchaseError(e);
  // Show user-friendly message
}
```

### 3. **Entitlement Checking**
```dart
// Use the provider for UI reactivity
final hasProAsync = ref.watch(hasProEntitlementProvider);

// Use simple function for backend logic
final hasPro = await checkProEntitlement();
```

### 4. **User Identification** (Optional)
```dart
import 'payments/rc_service.dart';

// When user logs in
await RevenueCatService().logIn(supabaseUserId);

// When user logs out
await RevenueCatService().logOut();
```

### 5. **Testing**
Use test API key for development:
- Test purchases won't charge
- Available in RevenueCat dashboard under Settings → API Keys

---

## Platform Configuration

### iOS Setup
No additional configuration needed. RevenueCat handles App Store integration.

### Android Setup
No additional configuration needed. RevenueCat handles Google Play integration.

---

## Troubleshooting

### "Entitlement not found"
- Verify entitlement name in RevenueCat dashboard matches `'Regen Global Pro'`
- Ensure offering is published
- Check that product is linked to entitlement

### "Product not available"
- Verify products are created in RevenueCat
- Check they're added to the offering
- Ensure offering is the current/default one

### "Network error"
- Check internet connection
- Verify RevenueCat API key is correct
- Check firewall/proxy settings

### "Purchase cancelled"
- This is normal user behavior - handle gracefully
- Don't show error to user
- Use `PurchaseErrorHandler.isCancelledError()` to detect

---

## Migration Guide: Test → Production

When ready to go live:

1. **Update API Key** in `initialize.dart`:
   ```dart
   const String apiKey = 'YOUR_PRODUCTION_API_KEY';
   ```

2. **Update RevenueCat Dashboard**:
   - Configure real products in App Store Connect and Google Play
   - Link to products in RevenueCat
   - Design production paywall

3. **Test Thoroughly**:
   - Use TestFlight for iOS
   - Use internal testing track for Android
   - Test all purchase flows

4. **Monitor**:
   - Watch RevenueCat analytics
   - Monitor error logs
   - Track subscription metrics

---

## API Reference Quick Link

https://www.revenuecat.com/docs/getting-started/installation/flutter

---

## Support Resources

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **Flutter Integration**: https://www.revenuecat.com/docs/getting-started/installation/flutter
- **Paywalls Guide**: https://www.revenuecat.com/docs/tools/paywalls
- **Customer Center**: https://www.revenuecat.com/docs/tools/customer-center

---

## Next Steps

1. ✓ Integration complete
2. Test all flows locally
3. Set up RevenueCat products and offering
4. Design paywall in RevenueCat dashboard
5. Test with TestFlight/Internal testing
6. Deploy to production
7. Monitor analytics and revenue
