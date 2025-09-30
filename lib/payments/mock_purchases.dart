import 'package:supabase_flutter/supabase_flutter.dart';
import 'purchase_service.dart';

class MockPurchasesService implements PurchasesService {
  final _client = Supabase.instance.client;

  static const _pkgs = <PurchasePackage>[
    PurchasePackage(
      id: 'general_annual',
      display: 'General — Annual',
      price: '\$149 / year',
      plan: 'general',
      term: 'annual',
    ),
    PurchasePackage(
      id: 'general_quarterly',
      display: 'General — Quarterly',
      price: '\$24.99 / quarter',
      plan: 'general',
      term: 'quarterly',
    ),
    PurchasePackage(
      id: 'alliance_annual',
      display: 'Alliance — Annual',
      price: '\$599 / year',
      plan: 'alliance',
      term: 'annual',
    ),
    PurchasePackage(
      id: 'alliance_quarterly',
      display: 'Alliance — Quarterly',
      price: '\$249 / quarter',
      plan: 'alliance',
      term: 'quarterly',
    ),
  ];

  @override
  Future<List<PurchasePackage>> getPackages() async => _pkgs;

  @override
  Future<Entitlements> getEntitlements() async {
    final user = _client.auth.currentUser;
    if (user == null) return const Entitlements(alliance: false, general: false);

    try {
      // Ensure profile exists first
      await _ensureProfile(user.id);

      // Fetch the profile data
      final row = await _client
          .from('profiles')
          .select('plan, plan_term, status')
          .eq('user_id', user.id)
          .single();

      final plan = (row['plan'] as String?);
      final term = (row['plan_term'] as String?);
      final status = (row['status'] as String?);

      // Only grant entitlements if status is active
      final isActive = status == 'active';

      return Entitlements(
        alliance: isActive && plan == 'alliance',
        general: isActive && plan == 'general',
        plan: plan,
        term: term,
      );
    } catch (e) {
      // If there's any error, return no entitlements
      print('Error getting entitlements: $e');
      return const Entitlements(alliance: false, general: false);
    }
  }

  @override
  Future<Entitlements> purchase(PurchasePackage pkg) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in');
    }

    print('Starting purchase for user: ${user.id}');
    print('Package: ${pkg.id} (${pkg.plan}/${pkg.term})');

    try {
      // Ensure profile exists first
      await _ensureProfile(user.id);

      // Update existing profile
      print('Updating profile...');
      await _client
          .from('profiles')
          .update({
        'plan': pkg.plan,
        'plan_term': pkg.term,
        'status': 'active',
        'rc_last_event': {
          'mock': true,
          'purchased': pkg.id,
          'ts': DateTime.now().toIso8601String(),
        },
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', user.id);

      print('Profile updated successfully');

      return Entitlements(
        alliance: pkg.plan == 'alliance',
        general: pkg.plan == 'general',
        plan: pkg.plan,
        term: pkg.term,
      );
    } catch (e) {
      print('Purchase failed: $e');
      throw Exception('Purchase failed: $e');
    }
  }

  @override
  Future<Entitlements> restore() => getEntitlements();

  /// Ensures a profile row exists for the user
  Future<void> _ensureProfile(String userId) async {
    try {
      // Try to fetch existing profile
      final existing = await _client
          .from('profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        print('Creating profile for user: $userId');
        // Create profile if it doesn't exist
        await _client.from('profiles').insert({
          'user_id': userId,
          'full_name': '',
          'email': _client.auth.currentUser?.email ?? '',
          'plan': null,
          'plan_term': null,
          'status': 'none', // Must use 'none' - allowed values: active, grace, past_due, cancelled, none
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Profile created successfully');
      } else {
        print('Profile already exists for user: $userId');
      }
    } catch (e) {
      print('Error ensuring profile: $e');
      // If insert fails due to duplicate key, that's fine - profile already exists
      if (!e.toString().contains('duplicate key')) {
        rethrow;
      }
    }
  }
}