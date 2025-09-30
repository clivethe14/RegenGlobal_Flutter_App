import 'package:flutter/material.dart';
import 'models.dart';

String? validateField(FieldSpec spec, dynamic value) {
  final v = spec.validator;
  if (v.required) {
    final isEmpty = (value == null) ||
        (value is String && value.trim().isEmpty) ||
        (value is bool && value == false);
    if (isEmpty) return 'Required';
  }
  if (value is String) {
    if (v.minLength != null && value.length < v.minLength!) {
      return 'Min length ${v.minLength}';
    }
    if (v.maxLength != null && value.length > v.maxLength!) {
      return 'Max length ${v.maxLength}';
    }
    if (spec.type == FieldType.email && !value.contains('@')) {
      return 'Enter a valid email';
    }
    if (spec.type == FieldType.phone &&
        value.replaceAll(RegExp(r'[^0-9]'), '').length < 6) {
      return 'Enter a valid phone';
    }
  }
  if (value is num) {
    if (v.min != null && value < v.min!) return 'Min ${v.min}';
    if (v.max != null && value > v.max!) return 'Max ${v.max}';
  }
  return null;
}

/// Build a single form field widget bound to the given [value] and [onChanged].
Widget buildFieldWidget({
  required BuildContext context,
  required FieldSpec spec,
  required dynamic value,
  required void Function(dynamic) onChanged,
}) {
  switch (spec.type) {
    case FieldType.text:
    case FieldType.email:
    case FieldType.phone:
      return TextFormField(
        key: ValueKey(spec.id),
        initialValue: (value as String?) ?? '',
        decoration: InputDecoration(labelText: spec.label, hintText: spec.hint),
        keyboardType: spec.type == FieldType.phone
            ? TextInputType.phone
            : (spec.type == FieldType.email
            ? TextInputType.emailAddress
            : TextInputType.text),
        validator: (v) => validateField(spec, v ?? ''),
        onChanged: onChanged,
      );

    case FieldType.number:
      return TextFormField(
        key: ValueKey(spec.id),
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(labelText: spec.label, hintText: spec.hint),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          final s = (v ?? '').toString().trim();
          if (s.isEmpty) return validateField(spec, '');
          final n = num.tryParse(s);
          if (n == null) return 'Enter a number';
          return validateField(spec, n);
        },
        onChanged: (s) => onChanged(num.tryParse(s)),
      );

    case FieldType.multiline:
      return TextFormField(
        key: ValueKey(spec.id),
        initialValue: (value as String?) ?? '',
        decoration: InputDecoration(labelText: spec.label, hintText: spec.hint),
        maxLines: 4,
        validator: (v) => validateField(spec, v ?? ''),
        onChanged: onChanged,
      );

    case FieldType.dropdown:
      final items = spec.options ?? const <String>[];
      return DropdownButtonFormField<String>(
        key: ValueKey(spec.id),
        value: (value as String?),
        decoration: InputDecoration(labelText: spec.label),
        items:
        items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v),
        validator: (v) => validateField(spec, v ?? ''),
      );

    case FieldType.checkbox:
      return CheckboxListTile(
        key: ValueKey(spec.id),
        value: (value as bool?) ?? false,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(spec.label),
        controlAffinity: ListTileControlAffinity.leading,
        subtitle: spec.hint != null ? Text(spec.hint!) : null,
      );

    case FieldType.switch_:
      return SwitchListTile(
        key: ValueKey(spec.id),
        value: (value as bool?) ?? false,
        onChanged: (v) => onChanged(v),
        title: Text(spec.label),
        subtitle: spec.hint != null ? Text(spec.hint!) : null,
      );

    case FieldType.date:
      final display = value is DateTime ? _fmtDate(value) : '';
      // Controller-free pattern keeps focus stable across rebuilds
      return InkWell(
        key: ValueKey(spec.id),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value is DateTime ? value : now,
            firstDate: DateTime(now.year - 100),
            lastDate: DateTime(now.year + 20),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration:
          InputDecoration(labelText: spec.label, hintText: spec.hint),
          child: Text(display.isEmpty ? 'Select date' : display),
        ),
      );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
