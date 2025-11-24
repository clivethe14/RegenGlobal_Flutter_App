import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'rc_service.dart';

/// Provider for RevenueCat offerings (products/subscriptions)
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getOfferings();
  } catch (e) {
    print('Error fetching offerings: $e');
    return null;
  }
});

/// Provider for current offering
final currentOfferingProvider = FutureProvider<Offering?>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getCurrentOffering();
  } catch (e) {
    print('Error fetching current offering: $e');
    return null;
  }
});

/// Provider for customer info
final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getCustomerInfo();
  } catch (e) {
    print('Error fetching customer info: $e');
    return null;
  }
});

/// Provider for subscriber information
final subscriberInfoProvider = FutureProvider<SubscriberInfo?>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getSubscriberInfo();
  } catch (e) {
    print('Error fetching subscriber info: $e');
    return null;
  }
});

/// Provider for active entitlements
final activeEntitlementsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getActiveEntitlementIds();
  } catch (e) {
    print('Error fetching active entitlements: $e');
    return [];
  }
});

/// Provider for Pro entitlement status
final hasProEntitlementProvider = FutureProvider<bool>((ref) async {
  try {
    final rcService = RevenueCatService();
    return await rcService.hasProEntitlement();
  } catch (e) {
    print('Error checking pro entitlement: $e');
    return false;
  }
});

/// Helper to get packages from current offering
Future<List<Package>> getPackages() async {
  try {
    final rcService = RevenueCatService();
    final offering = await rcService.getCurrentOffering();
    return offering?.availablePackages ?? [];
  } catch (e) {
    print('Error getting packages: $e');
    return [];
  }
}

/// Get specific package by identifier
Future<Package?> getPackageByIdentifier(String identifier) async {
  try {
    final packages = await getPackages();
    for (final pkg in packages) {
      if (pkg.identifier == identifier) {
        return pkg;
      }
    }
    return null;
  } catch (e) {
    print('Error getting package: $e');
    return null;
  }
}

/// Get monthly package
Future<Package?> getMonthlyPackage() async {
  return getPackageByIdentifier('monthly');
}

/// Get yearly package
Future<Package?> getYearlyPackage() async {
  return getPackageByIdentifier('yearly');
}

/// Get 3-month package
Future<Package?> getThreeMonthPackage() async {
  return getPackageByIdentifier('three_month');
}

/// Purchase a package with error handling
Future<bool> purchasePackage(Package package) async {
  try {
    final rcService = RevenueCatService();
    await rcService.purchasePackage(package);
    return true;
  } catch (e) {
    print('Error purchasing package: $e');
    return false;
  }
}
