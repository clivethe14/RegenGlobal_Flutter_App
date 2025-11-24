import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Service Layer
/// Handles all RevenueCat operations including purchases, entitlements, and customer info
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() {
    return _instance;
  }

  RevenueCatService._internal();

  /// Get the current customer's entitlements
  Future<Map<String, EntitlementInfo>> getEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active;
    } catch (e) {
      print('Error getting entitlements: $e');
      rethrow;
    }
  }

  /// Check if user has a specific entitlement
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final entitlements = await getEntitlements();
      return entitlements.containsKey(entitlementId);
    } catch (e) {
      print('Error checking entitlement: $e');
      return false;
    }
  }

  /// Check specifically for "Regen Global Pro" entitlement
  Future<bool> hasProEntitlement() async {
    return hasEntitlement('Regen Global Pro');
  }

  /// Check for Alliance entitlement
  Future<bool> hasAllianceEntitlement() async {
    return hasEntitlement('alliance');
  }

  /// Check for General entitlement
  Future<bool> hasGeneralEntitlement() async {
    return hasEntitlement('general');
  }

  /// Check for Associate entitlement
  Future<bool> hasAssociateEntitlement() async {
    return hasEntitlement('associate');
  }

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('Error getting customer info: $e');
      rethrow;
    }
  }

  /// Get offerings (products grouped by tier)
  Future<Offerings> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      print('✅ [RevenueCat] Offerings retrieved successfully');
      print('   - Available offerings: ${offerings.all.keys.toList()}');
      for (var offering in offerings.all.values) {
        print(
          '   - Offering "${offering.identifier}": ${offering.availablePackages.length} packages',
        );
        for (var pkg in offering.availablePackages) {
          print('     - Package: ${pkg.identifier}');
        }
      }
      return offerings;
    } catch (e) {
      print('❌ [RevenueCat] Error getting offerings: $e');
      rethrow;
    }
  }

  /// Get current offering (usually the main one)
  Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await getOfferings();
      return offerings.current;
    } catch (e) {
      print('Error getting current offering: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      print('Purchase successful!');
      return purchaseResult.customerInfo;
    } catch (e) {
      print('Error during purchase: $e');
      rethrow;
    }
  }

  /// Restore previous purchases
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      print('Purchases restored successfully!');
      return customerInfo;
    } catch (e) {
      print('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Log in user (useful for multi-device sync)
  Future<CustomerInfo> logIn(String userId) async {
    try {
      final logInResult = await Purchases.logIn(userId);
      print('User $userId logged in successfully');
      return logInResult.customerInfo;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  /// Log out user
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      print('User logged out');
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  /// Check subscription status for "Regen Global Pro"
  Future<bool> isSubscriptionActive() async {
    try {
      return await hasProEntitlement();
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  /// Get all active entitlements (returns list of entitlement IDs)
  Future<List<String>> getActiveEntitlementIds() async {
    try {
      final entitlements = await getEntitlements();
      return entitlements.keys.toList();
    } catch (e) {
      print('Error getting active entitlements: $e');
      return [];
    }
  }

  /// Get subscriber info with expiration dates
  Future<SubscriberInfo> getSubscriberInfo() async {
    try {
      final customerInfo = await getCustomerInfo();
      final proEntitlement =
          customerInfo.entitlements.active['Regen Global Pro'];

      return SubscriberInfo(
        activeEntitlements: customerInfo.entitlements.active.keys.toList(),
        proExpirationDate: proEntitlement?.expirationDate,
      );
    } catch (e) {
      print('Error getting subscriber info: $e');
      rethrow;
    }
  }
}

/// Model for subscriber information
class SubscriberInfo {
  final List<String> activeEntitlements;
  final dynamic proExpirationDate;

  SubscriberInfo({required this.activeEntitlements, this.proExpirationDate});

  bool get isPro => activeEntitlements.contains('Regen Global Pro');

  bool get isProExpired {
    if (proExpirationDate == null) return false;
    if (proExpirationDate is DateTime) {
      return (proExpirationDate as DateTime).isBefore(DateTime.now());
    }
    return false;
  }
}
