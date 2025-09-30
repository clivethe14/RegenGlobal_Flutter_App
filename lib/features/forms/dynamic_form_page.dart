import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // add this
import '../catalogs/catalog.dart';
import '../../core/form_engine/models.dart';
import '../../core/form_engine/widgets.dart';
import '../../core/form_engine/submission_service.dart';
import '../../dev/dev_tools.dart'; // for dashboardPathForPlan()


/// Submission service DI: swap this with a real HTTP/db writer when ready.
final submissionServiceProvider =
Provider<SubmissionService>((ref) => SupabaseSubmissionService());

/// Holds the current form values as a map { fieldId: value } keyed by formId.
final formStateProvider =
StateProvider.family<Map<String, dynamic>, String>((ref, formId) => {});

class DynamicFormPage extends ConsumerStatefulWidget {
  final String formId;
  final Map<String, dynamic>? initialValues; // already added earlier
  const DynamicFormPage({super.key, required this.formId, this.initialValues});

  @override
  ConsumerState<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends ConsumerState<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _seeded = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_seeded && widget.initialValues != null && widget.initialValues!.isNotEmpty && mounted) {
        final formId = widget.formId;
        final current = ref.read(formStateProvider(formId));
        ref.read(formStateProvider(formId).notifier).state = {
          ...current,
          ...widget.initialValues!,
        };
        _seeded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formId = widget.formId;
    final config = formCatalog[formId];
    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Form')),
        body: Center(child: Text('Form "$formId" not found.')),
      );
    }

    final state = ref.watch(formStateProvider(formId));

    return Scaffold(
      appBar: AppBar(title: Text(config.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView.separated(
                itemCount: config.fields.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == config.fields.length) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        icon: _submitting
                            ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.send),
                        label: Text(_submitting ? 'Submitting...' : 'Submit'),
                        onPressed: _submitting ? null : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) return;

                          setState(() => _submitting = true);
                          try {
                            final payload = ref.read(formStateProvider(formId));
                            await ref.read(submissionServiceProvider)
                                .submit(formId: formId, payload: payload);

                            if (!mounted) return;

                            // Show a success MaterialBanner
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.hideCurrentMaterialBanner();
                            messenger.showMaterialBanner(
                              MaterialBanner(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                content: const Text('Thanks! Your request was submitted successfully.'),
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                actions: [
                                  TextButton(
                                    onPressed: () => messenger.hideCurrentMaterialBanner(),
                                    child: const Text('Dismiss'),
                                  ),
                                ],
                              ),
                            );

                            // Give users a moment to see it, then redirect
                            await Future.delayed(const Duration(milliseconds: 1500));
                            messenger.hideCurrentMaterialBanner();

                            if (!mounted) return;
                            context.go(dashboardPathForPlan()); // sends alliance users to /dashboard/alliance, others to /dashboard/general
// GoRouter: go back to dashboard
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Submit failed: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                      ),
                    );
                  }

                  final spec = config.fields[index];
                  final value = state[spec.id];
                  return buildFieldWidget(
                    context: context,
                    spec: spec,
                    value: value,
                    onChanged: (v) {
                      final map = {...ref.read(formStateProvider(formId))};
                      map[spec.id] = v;
                      ref.read(formStateProvider(formId).notifier).state = map;
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

