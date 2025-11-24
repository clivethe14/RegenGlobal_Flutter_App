import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'submission_service.dart';

/// Provides the SupabaseSubmissionService singleton.
final submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SupabaseSubmissionService();
});
