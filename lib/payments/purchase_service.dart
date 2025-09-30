// A minimal seam so we can swap Mock ↔ RevenueCat later without UI changes.

abstract class PurchasesService {
  Future<List<PurchasePackage>> getPackages();
  Future<Entitlements> purchase(PurchasePackage pkg);
  Future<Entitlements> getEntitlements();
  Future<Entitlements> restore();
}

class PurchasePackage {
  final String id;        // e.g., 'alliance_annual'
  final String display;   // UI label, e.g., 'Alliance — Annual'
  final String price;     // e.g., '$99.99 / year' (mock hard-coded)
  final String plan;      // 'alliance' | 'general'
  final String term;      // 'annual' | 'quarterly'
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
  final String? plan;     // 'alliance'|'general' or null
  final String? term;     // 'annual'|'quarterly' or null
  const Entitlements({
    required this.alliance,
    required this.general,
    this.plan,
    this.term,
  });
}
