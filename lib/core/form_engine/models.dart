import 'package:flutter/material.dart';


/// Types of fields supported by the form engine.
enum FieldType { text, number, email, phone, multiline, dropdown, checkbox, switch_, date }


/// Validation rules (expand as needed).
class ValidatorSpec {
  final bool required;
  final int? minLength;
  final int? maxLength;
  final num? min;
  final num? max;


  const ValidatorSpec({
    this.required = false,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
  });
}


/// Field definition (schema).
class FieldSpec {
  final String id; // key in the output map
  final String label;
  final FieldType type;
  final String? hint;
  final List<String>? options; // for dropdown
  final ValidatorSpec validator;


  const FieldSpec({
    required this.id,
    required this.label,
    required this.type,
    this.hint,
    this.options,
    this.validator = const ValidatorSpec(),
  });
}


/// Per-form configuration.
class FormConfig {
  final String id;
  final String title;
  final String? description;
  final List<FieldSpec> fields;
  final String? submitEndpoint; // reserved for future use


  const FormConfig({
    required this.id,
    required this.title,
    this.description,
    required this.fields,
    this.submitEndpoint,
  });
}


/// Dashboard link: either opens a form or an external URL.
enum DestinationType { form, external, list }


class LinkSpec {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final DestinationType destinationType;
  final String? formId; // when destinationType == form
  final String? url; // when destinationType == external
  final String? listId;


  const LinkSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.destinationType,
    this.formId,
    this.url,
    this.listId
  });
}

class ListItemSpec {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  /// Prefill map to seed the target form fields
  final Map<String, dynamic> prefill;
  final String? linkUrl;

  const ListItemSpec({
    required this.id,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.prefill = const {},
    this.linkUrl,
  });
}

class ItemListConfig {
  final String id;
  final String title;
  final String? description;
  final String? targetFormId;
  final List<ListItemSpec> items;

  const ItemListConfig({
    required this.id,
    required this.title,
    this.description,
    this.targetFormId,
    required this.items,
  });
}