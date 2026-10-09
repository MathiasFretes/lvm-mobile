import 'dart:convert';

/// The WorshipContext 0.1 handoff owned by LVM Service.
///
/// It contains service identity and scheduling only. Service items, people,
/// permissions and Presenter settings do not belong to this contract.
final class WorshipContextDocument {
  const WorshipContextDocument({
    required this.serviceId,
    required this.title,
    required this.startsAt,
    required this.startsAtIso,
    required this.setlistId,
    required this.name,
  });

  final String serviceId;
  final String title;
  final DateTime startsAt;
  final String startsAtIso;
  final String setlistId;
  final String name;

  static WorshipContextDocument parseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('El archivo no contiene JSON válido.');
    }
    return parse(decoded);
  }

  static WorshipContextDocument parse(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('context: se requiere un objeto.');
    }
    const fields = {
      'schemaVersion',
      'serviceId',
      'title',
      'startsAt',
      'setlistId',
      'name',
    };
    for (final key in value.keys) {
      if (!fields.contains(key)) {
        throw FormatException('context.$key: campo desconocido.');
      }
    }
    if (value['schemaVersion'] != '0.1') {
      throw const FormatException('context.schemaVersion: se requiere 0.1.');
    }
    String text(String key) {
      final field = value[key];
      if (field is! String || field.trim().isEmpty) {
        throw FormatException('context.$key: se requiere texto no vacío.');
      }
      return field;
    }

    final startsAtIso = text('startsAt');
    final startsAt = DateTime.tryParse(startsAtIso);
    if (startsAt == null) {
      throw const FormatException('context.startsAt: fecha inválida.');
    }
    return WorshipContextDocument(
      serviceId: text('serviceId'),
      title: text('title'),
      startsAt: startsAt,
      startsAtIso: startsAtIso,
      setlistId: text('setlistId'),
      name: text('name'),
    );
  }
}
