import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dynamic_form_page.dart';
import '../../core/form_engine/submission_provider.dart';

/// Wrapper that provides submission handler to DynamicFormPage.
class DynamicFormPageWrapper extends ConsumerWidget {
  const DynamicFormPageWrapper({
    super.key,
    this.formId,
    this.title,
    this.initialValues,
  });

  final String? formId;
  final String? title;
  final Map<String, dynamic>? initialValues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionService = ref.read(submissionServiceProvider);

    return DynamicFormPage(
      formId: formId,
      title: title,
      initialValues: initialValues,
      onSubmit: (values) async {
        if (formId != null) {
          await submissionService.submit(
            formId: formId!,
            payload: values,
          );
        }
      },
    );
  }
}
