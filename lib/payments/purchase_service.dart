// A minimal seam so we can swap Mock ↔ RevenueCat later without UI changes.
import 'rc_service.dart';

abstract class PurchasesService {
  Future<List<PurchasePackage>> getPackages();
  Future<Entitlements> purchase(PurchasePackage pkg);
  Future<Entitlements> getEntitlements();
  Future<Entitlements> restore();
}

abstract class PurchaseService {
  /// Purchase a product/plan (e.g., 'alliance_annual', 'alliance_quarterly')
  Future<bool> purchasePlan(String productId);

  /// Whether the user currently has an entitlement (e.g., 'alliance', 'general')
  Future<bool> hasEntitlement(String entitlement);

  /// Restore purchases
  Future<void> restorePurchases();
}

class PurchasePackage {
  final String id; // e.g., 'alliance_annual'
  final String display; // UI label, e.g., 'Alliance — Annual'
  final String price; // e.g., '$99.99 / year' (mock hard-coded)
  final String plan; // 'alliance' | 'general'
  final String term; // 'annual' | 'quarterly'
  const PurchasePackage({
    required this.id,
    required this.display,
    required this.price,
    required this.plan,
    required this.term,
  });
}

class Entitlements {
  final bool alliance;
  final bool general;
  final String? plan; // 'alliance'|'general' or null
  final String? term; // 'annual'|'quarterly' or null
  const Entitlements({
    required this.alliance,
    required this.general,
    this.plan,
    this.term,
  });
}

class RevenueCatPurchaseService implements PurchaseService {
  // Optional: map your plan IDs to RC package identifiers if they differ
  String _mapProductToPackageId(String productId) {
    // If your RevenueCat Package identifiers match your productId, just return productId.
    // Otherwise map here (e.g., 'alliance_annual' -> 'annual_alliance_pkg')
    return productId;
  }

  @override
  Future<bool> purchasePlan(String productId) async {
    final rc = RevenueCatService();
    try {
      final offering = await rc.getCurrentOffering();
      if (offering == null) {
        throw Exception('No current offering is configured in RevenueCat.');
      }

      final packageId = _mapProductToPackageId(productId);
      final pkg = offering.availablePackages.firstWhere(
        (p) => p.identifier == packageId,
        orElse: () => throw Exception('Package $packageId not found'),
      );

      final customerInfo = await rc.purchasePackage(pkg);
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      // Log/handle as needed; return false for failure
      return false;
    }
  }

  @override
  Future<bool> hasEntitlement(String entitlement) async {
    final rc = RevenueCatService();
    try {
      return await rc.hasEntitlement(entitlement);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    final rc = RevenueCatService();
    await rc.restorePurchases();
  }
}
