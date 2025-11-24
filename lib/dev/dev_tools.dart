// lib/dev/dev_tools.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Update the current user's plan metadata. Accepts 'alliance' or 'general'.
Future<void> switchPlan(String plan) async {
  await Supabase.instance.client.auth.updateUser(
    UserAttributes(data: {'plan': plan}),
  );
}

/// Read the current plan from user metadata, defaulting to 'general'.
String currentPlan() {
  final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
  final plan = (meta?['plan'] as String?)?.toLowerCase();
  return (plan == 'alliance') ? 'alliance' : 'general';
}

/// Return the dashboard route path for the current (or provided) plan.
String dashboardPathForPlan([String? plan]) {
  final p = (plan ?? currentPlan()).toLowerCase();
  if (p == 'alliance') return '/dashboard/alliance';
  if (p == 'associate') return '/dashboard/associate';
  return '/dashboard/general';
}
