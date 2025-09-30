// lib/core/form_engine/submission_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract contract (kept for DI/testability).
abstract class SubmissionService {
  Future<void> submit({
    required String formId,
    required Map<String, dynamic> payload,
  });
}

/// Optional no-op for testing.
class DebugSubmissionService implements SubmissionService {
  const DebugSubmissionService();
  @override
  Future<void> submit({
    required String formId,
    required Map<String, dynamic> payload,
  }) async {
    // no-op
  }
}

/// ---------------- JSON helpers ----------------

String _fmtYmd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Make any value JSON-encodable (converts DateTime to ISO8601).
dynamic _jsonSafe(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v.toIso8601String();
  if (v is List) return v.map(_jsonSafe).toList();
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), _jsonSafe(val)));
  }
  return v; // num, String, bool are already JSON-safe
}

/// For Postgres DATE columns, prefer 'YYYY-MM-DD'.
String? _asYmd(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return _fmtYmd(v);
  if (v is String) return v;
  return null;
}

/// ---------------- Supabase service ----------------

class SupabaseSubmissionService implements SubmissionService {
  final SupabaseClient _client;

  /// Table names (override in constructor if you named them differently).
  final String consultantsTable;
  final String contractorsTable;
  final String spatialBookingsTable;
  final String magazineAdsTable;

  SupabaseSubmissionService({
    SupabaseClient? client,
    this.consultantsTable = 'consultant_requests',
    this.contractorsTable = 'contractor_requests',
    this.spatialBookingsTable = 'spatial_bookings',
    this.magazineAdsTable = 'magazine_ad_requests',
  }) : _client = client ?? Supabase.instance.client;

  String _tableFor(String formId, Map<String, dynamic> payload) {
    final fid = formId.toLowerCase().trim();

    // Alliance-only forms
    if (fid == 'spatial_booking') return spatialBookingsTable;
    if (fid == 'magazine_ad_request') return magazineAdsTable;

    // Consultants / Contractors contact form
    if (fid == 'contact_request') {
      final seg = (payload['segment'] ?? '').toString().toLowerCase().trim();
      if (seg == 'contractors') return contractorsTable;
      return consultantsTable; // default to consultants
    }

    // Fallback (rare)
    return consultantsTable;
  }

  @override
  Future<void> submit({
    required String formId,
    required Map<String, dynamic> payload,
  }) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw Exception('Not signed in. Please sign in to submit.');
    }

    // Ensure payload has no raw DateTime objects.
    final safePayload = (_jsonSafe(payload) as Map<String, dynamic>);
    final table = _tableFor(formId, payload);

    // Base columns shared by all tables.
    final record = <String, dynamic>{
      'form_id': formId,
      'form_version': safePayload['_formVersion'],
      'payload': safePayload,
      'submitted_at': DateTime.now().toIso8601String(),
      // NOTE: If you set DEFAULT auth.uid() on user_id in SQL, you don't need to send user_id here.
    };

    // Add only columns that exist on the destination table.
    if (table == spatialBookingsTable) {
      // spatial_bookings schema:
      // org_name, contact_name, email, phone, preferred_date (DATE), time_slot, booth_size
      record.addAll({
        'org_name': safePayload['orgName'],
        'contact_name': safePayload['contactName'],
        'email': safePayload['email'],
        'phone': safePayload['phone'],
        'preferred_date': _asYmd(payload['preferredDate']),
        'time_slot': safePayload['timeSlot'],
        'booth_size': safePayload['boothSize'],
      });
    } else if (table == magazineAdsTable) {
      // magazine_ad_requests schema:
      // org_name, contact_name, email, phone, preferred_issue, ad_size, placement, budget, notes
      record.addAll({
        'org_name': safePayload['orgName'],
        'contact_name': safePayload['contactName'],
        'email': safePayload['email'],
        'phone': safePayload['phone'],
        'preferred_issue': safePayload['preferredIssue'],
        'ad_size': safePayload['adSize'],
        'placement': safePayload['placement'],
        'budget': safePayload['budget'],
        'notes': safePayload['notes'],
      });
    } else {
      // consultant_requests / contractor_requests schema:
      // full_name, email, phone, requirement, domain
      record.addAll({
        'full_name': safePayload['fullName'],
        'email': safePayload['email'],
        'phone': safePayload['phone'],
        'requirement': safePayload['requirement'],
        'domain': safePayload['domain'],
      });
    }

    // Optional: log the destination (helpful during dev)
    // ignore: avoid_print
    // print('[Submission] form=$formId -> table=$table, record keys=${record.keys.toList()}');

    await _client.from(table).insert(record);
  }
}
