import 'rc_service.dart';

/// Check if user has the "Regen Global Pro" entitlement
Future<bool> checkProEntitlement() async {
  try {
    final rcService = RevenueCatService();
    return await rcService.hasProEntitlement();
  } catch (e) {
    print('Error checking pro entitlement: $e');
    return false;
  }
}

/// Get comprehensive subscriber information
Future<SubscriberInfo> getSubscriberInfo() async {
  try {
    final rcService = RevenueCatService();
    return await rcService.getSubscriberInfo();
  } catch (e) {
    print('Error getting subscriber info: $e');
    rethrow;
  }
}

/// Sync purchases with RevenueCat
Future<void> syncPurchases() async {
  try {
    final rcService = RevenueCatService();
    await rcService.restorePurchases();
    print('Purchases synced successfully');
  } catch (e) {
    print('Error syncing purchases: $e');
    rethrow;
  }
}
