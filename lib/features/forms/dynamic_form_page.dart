// lib/features/forms/dynamic_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/form_engine/models.dart';
import '../catalogs/catalog.dart';

/// Single form state for this page instance.
/// If you ever need multiple forms on-screen simultaneously, migrate this to a `.family`.
final formStateProvider = StateProvider.autoDispose<Map<String, dynamic>>(
    (ref) => <String, dynamic>{});

class DynamicFormPage extends ConsumerStatefulWidget {
  const DynamicFormPage({
    super.key,
    this.formId,
    this.title,
    this.initialValues,
    this.onSubmit,
  });

  final String? formId;
  final String? title;
  final Map<String, dynamic>? initialValues;
  final Future<void> Function(Map<String, dynamic> values)? onSubmit;

  @override
  ConsumerState<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends ConsumerState<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late FormConfig? _formConfig;

  @override
  void initState() {
    super.initState();

    // Get form config from catalog
    _formConfig = widget.formId != null ? formCatalog[widget.formId] : null;

    _controllers = {};

    // Initialize controllers for all text-like fields (including date)
    if (_formConfig != null) {
      for (final field in _formConfig!.fields) {
        if ([
          FieldType.text,
          FieldType.email,
          FieldType.phone,
          FieldType.number,
          FieldType.multiline,
          FieldType.date
        ].contains(field.type)) {
          _controllers[field.id] = TextEditingController();
        }
      }
    }

    // Seed provider and controllers
    Future.microtask(() {
      final seed = <String, dynamic>{...?widget.initialValues};

      if (_formConfig != null) {
        for (final field in _formConfig!.fields) {
          if (!seed.containsKey(field.id)) {
            if ([
              FieldType.text,
              FieldType.email,
              FieldType.phone,
              FieldType.number,
              FieldType.multiline,
              FieldType.date
            ].contains(field.type)) {
              seed[field.id] = '';
            } else if (field.type == FieldType.dropdown &&
                field.options != null) {
              seed[field.id] =
                  field.options!.isNotEmpty ? field.options!.first : '';
            } else if (field.type == FieldType.checkbox ||
                field.type == FieldType.switch_) {
              seed[field.id] = false;
            }
          }
        }
      }

      seed['formId'] = widget.formId;

      ref.read(formStateProvider.notifier).update((prev) => <String, dynamic>{
            ...prev,
            ...seed,
          });

      // Initialize controllers from seeded state
      for (final entry in _controllers.entries) {
        _controllers[entry.key]!.text = (seed[entry.key] ?? '') as String;
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateField(String key, dynamic value) {
    ref.read(formStateProvider.notifier).update(
          (prev) => <String, dynamic>{...prev, key: value},
        );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final values = ref.read(formStateProvider);

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(values);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted successfully')),
      );

      Navigator.of(context).maybePop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: $e')),
      );
    }
  }

  String? _validateField(FieldSpec field, String value) {
    final validator = field.validator;

    if (validator.required && (value.isEmpty)) {
      return '${field.label} is required';
    }

    if (value.isNotEmpty) {
      if (validator.minLength != null && value.length < validator.minLength!) {
        return '${field.label} must be at least ${validator.minLength} characters';
      }
      if (validator.maxLength != null && value.length > validator.maxLength!) {
        return '${field.label} must be at most ${validator.maxLength} characters';
      }

      if (field.type == FieldType.email) {
        final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
        if (!ok) return 'Enter a valid email';
      }

      if (field.type == FieldType.number) {
        final num? numVal = num.tryParse(value);
        if (numVal == null) return 'Enter a valid number';
        if (validator.min != null && numVal < validator.min!) {
          return '${field.label} must be at least ${validator.min}';
        }
        if (validator.max != null && numVal > validator.max!) {
          return '${field.label} must be at most ${validator.max}';
        }
      }
    }

    return null;
  }

  Widget _buildField(FieldSpec field, Map<String, dynamic> formValues) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.email:
      case FieldType.phone:
      case FieldType.number:
      case FieldType.multiline:
        return TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          keyboardType: field.type == FieldType.email
              ? TextInputType.emailAddress
              : field.type == FieldType.phone
                  ? TextInputType.phone
                  : field.type == FieldType.number
                      ? TextInputType.number
                      : TextInputType.text,
          maxLines: field.type == FieldType.multiline ? 4 : 1,
          minLines: field.type == FieldType.multiline ? 4 : 1,
          onChanged: (v) => _updateField(field.id, v),
          validator: (v) => _validateField(field, v ?? ''),
        );

      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: formValues[field.id] as String? ??
              (field.options?.firstOrNull ?? ''),
          items: (field.options ?? [])
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (value) => _updateField(field.id, value),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
          ),
          validator: (v) => field.validator.required && (v == null || v.isEmpty)
              ? '${field.label} is required'
              : null,
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: formValues[field.id] as bool? ?? false,
          onChanged: (v) => _updateField(field.id, v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        );

      case FieldType.switch_:
        return SwitchListTile(
          title: Text(field.label),
          value: formValues[field.id] as bool? ?? false,
          onChanged: (v) => _updateField(field.id, v),
        );

      case FieldType.date:
        return TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint ?? 'YYYY-MM-DD',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final formatted = picked.toIso8601String().split('T')[0];
              _updateField(field.id, formatted);
              _controllers[field.id]?.text = formatted;
            }
          },
          validator: (v) => field.validator.required && (v == null || v.isEmpty)
              ? '${field.label} is required'
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(formStateProvider);

    final title = widget.title ?? (_formConfig?.title ?? 'Form');
    final description = _formConfig?.description;

    if (_formConfig == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Form')),
        body: const Center(
          child: Text('Form not found in catalog'),
        ),
      );
    }

    final formValues = ref.read(formStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null) ...[
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],
                ..._formConfig!.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildField(field, formValues),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
