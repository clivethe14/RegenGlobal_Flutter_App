# Paywall Changes: 6-Month & Yearly Subscriptions Only

## Overview
Currently, the paywall supports various subscription periods (monthly, quarterly, annual). The request is to simplify to only **6-month and yearly** subscriptions for all subscription tiers (Alliance, General, Associate).

## Changes Required

### 1. **RevenueCat Dashboard Configuration** (Manual - No Code)
**Location:** RevenueCat Console → Products & Entitlements

**For each tier (Alliance, General, Associate):**

1. **Delete/Archive existing packages:**
   - Monthly ($rc_monthly)
   - Quarterly ($rc_three_month)
   - Annual ($rc_annual) - Optional, can keep if needed

2. **Create 2 new packages:**
   - **6-Month Package** 
     - Identifier: `$rc_six_month` (or `{tier}_six_month`)
     - Duration: 6 months
     - Billing cycle: Every 6 months
   
   - **Yearly Package**
     - Identifier: `$rc_annual` (keep existing)
     - Duration: 12 months
     - Billing cycle: Every year

3. **Link to Entitlements:**
   - Both packages → "general" entitlement (for General tier)
   - Both packages → "alliance" entitlement (for Alliance tier)
   - Both packages → "associate" entitlement (for Associate tier)

### 2. **Dart Code Changes**

#### File: `lib/features/paywall/paywall_page_rc.dart`

**Update `_getPackageDisplayName()` method:**

```dart
String _getPackageDisplayName(String identifier) {
  if (identifier.toLowerCase().contains('annual') || 
      identifier.toLowerCase().contains('yearly')) {
    return 'Yearly';
  }
  if (identifier.toLowerCase().contains('six_month') || 
      identifier.toLowerCase().contains('6_month') ||
      identifier == '\$rc_six_month') {
    return '6 Months';
  }
  return identifier;
}
```

**Optional improvements:**

1. **Show pricing benefit** - Add discount indicator:
```dart
String _getMonthlyEquivalent(Package package) {
  final monthly = package.storeProduct.price / 
    (package.storeProduct.billingPeriod?.value ?? 1);
  return '${monthly.toStringAsFixed(2)}/month';
}
```

2. **Highlight yearly as "best value"** in UI if desired

### 3. **Testing Checklist**

- [ ] RevenueCat Console products created with correct identifiers
- [ ] Packages linked to correct entitlements
- [ ] Offerings fetched successfully in app
- [ ] Only 6-month and yearly packages display in paywall
- [ ] Package names display correctly as "6 Months" and "Yearly"
- [ ] Purchases work for both packages
- [ ] Entitlements granted correctly after purchase
- [ ] All three tiers (Alliance, General, Associate) show both packages

### 4. **Package Identifier Reference**

Standard RevenueCat package identifiers:
- 6-month: `$rc_six_month`
- Yearly: `$rc_annual`

Or custom per-tier:
- Alliance 6-month: `alliance_six_month`, Alliance yearly: `alliance_annual`
- General 6-month: `general_six_month`, General yearly: `general_annual`
- Associate 6-month: `associate_six_month`, Associate yearly: `associate_annual`

### 5. **Current Paywall Package Display Logic**

The paywall currently handles these package identifiers:
- `monthly` / `$rc_monthly` → "Monthly"
- `quarterly` / `three_month` / `$rc_three_month` → "Quarterly"
- `annual` / `yearly` / `$rc_annual` → "Annual"

**Action:** Update this logic to only handle:
- `six_month` / `$rc_six_month` → "6 Months"
- `annual` / `$rc_annual` → "Yearly"

### 6. **Future Optimization**

Consider adding these features later:
- Discount badge showing "Save X% yearly"
- Comparison table: 6-month vs yearly pricing
- Annual pre-select recommendation
- Trial period handling if needed

## Implementation Order

1. **Step 1:** Update RevenueCat Console products (create 6-month, remove monthly/quarterly)
2. **Step 2:** Update `_getPackageDisplayName()` method in paywall_page_rc.dart
3. **Step 3:** Test on dev/staging environment
4. **Step 4:** Verify all three tiers show both packages correctly
5. **Step 5:** Deploy to production

## No Breaking Changes

✅ This change does not require:
- Database migrations
- Entitlement name changes
- Authentication flow changes
- Dashboard routing changes
- Supabase schema updates

The only changes are:
- RevenueCat product configuration (manual)
- One method update in paywall_page_rc.dart (code)
