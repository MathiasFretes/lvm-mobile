import 'dart:convert';

/// Read-only view of the Service 0.1 file owned by LVM Service.
///
/// Validation follows `LVM Service/src/contracts/service.ts`. The source JSON
/// remains the exchange format; these summaries are only for the mobile UI.
final class ServiceDocument {
  const ServiceDocument({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.startsAtIso,
    required this.setlistName,
    required this.items,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String startsAtIso;
  final String setlistName;
  final List<ServiceDocumentItem> items;

  static ServiceDocument parseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('El archivo no contiene JSON válido.');
    }
    return parse(decoded);
  }

  static ServiceDocument parse(Object? value) {
    final service = _object(value, 'service', {
      'schemaVersion',
      'id',
      'title',
      'startsAt',
      'setlist',
      'items',
    });
    if (service['schemaVersion'] != '0.1') {
      throw const FormatException('service.schemaVersion: se requiere 0.1.');
    }
    final rawDate = _text(service['startsAt'], 'service.startsAt');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T.*(?:Z|[+-]\d{2}:\d{2})$')
            .hasMatch(rawDate) ||
        DateTime.tryParse(rawDate) == null) {
      throw const FormatException(
        'service.startsAt: se requiere fecha y hora ISO con zona horaria.',
      );
    }
    final setlist = _object(service['setlist'], 'service.setlist', {
      'id',
      'name',
    });
    _text(setlist['id'], 'service.setlist.id');
    final rawItems = service['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      throw const FormatException(
        'service.items: se requiere al menos un elemento.',
      );
    }
    final ids = <String>{};
    final items = <ServiceDocumentItem>[];
    for (var index = 0; index < rawItems.length; index++) {
      final path = 'service.items[$index]';
      final item = _object(rawItems[index], path, {
        'id',
        'kind',
        'song',
        'scripture',
        'announcement',
        'sermon',
      });
      final id = _text(item['id'], '$path.id');
      if (!ids.add(id)) throw FormatException('$path.id: ID duplicado.');
      final kind = _text(item['kind'], '$path.kind');
      final payload = switch (kind) {
        'SONG' => 'song',
        'SCRIPTURE' => 'scripture',
        'ANNOUNCEMENT' => 'announcement',
        'SERMON' => 'sermon',
        _ => throw FormatException('$path.kind: tipo no compatible.'),
      };
      for (final key in ['song', 'scripture', 'announcement', 'sermon']) {
        if (key != payload && item.containsKey(key)) {
          throw FormatException('$path.$key: payload incompatible.');
        }
      }
      items.add(_parseItem(id, kind, item[payload], '$path.$payload'));
    }
    return ServiceDocument(
      id: _text(service['id'], 'service.id'),
      title: _text(service['title'], 'service.title'),
      startsAt: DateTime.parse(rawDate),
      startsAtIso: rawDate,
      setlistName: _text(setlist['name'], 'service.setlist.name'),
      items: List.unmodifiable(items),
    );
  }
}

final class ServiceDocumentItem {
  const ServiceDocumentItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
  });

  final String id;
  final String kind;
  final String title;
  final String detail;
}

ServiceDocumentItem _parseItem(
  String id,
  String kind,
  Object? value,
  String path,
) {
  if (kind == 'SONG') {
    final song = _object(value, path, {'id', 'title', 'key', 'sections'});
    _text(song['id'], '$path.id');
    final title = _text(song['title'], '$path.title');
    if (song['key'] is! String) {
      throw FormatException('$path.key: se requiere texto.');
    }
    final sections = song['sections'];
    if (sections is! List || sections.isEmpty) {
      throw FormatException(
        '$path.sections: se requiere al menos una sección.',
      );
    }
    for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
      final sectionPath = '$path.sections[$sectionIndex]';
      final section = _object(sections[sectionIndex], sectionPath, {
        'kind',
        'label',
        'lines',
      });
      _text(section['kind'], '$sectionPath.kind');
      _text(section['label'], '$sectionPath.label');
      final lines = section['lines'];
      if (lines is! List || lines.isEmpty) {
        throw FormatException(
          '$sectionPath.lines: se requiere al menos una línea.',
        );
      }
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        final linePath = '$sectionPath.lines[$lineIndex]';
        final line = _object(lines[lineIndex], linePath, {'text', 'chords'});
        final text = _text(line['text'], '$linePath.text');
        final chords = line['chords'];
        if (chords is! List) {
          throw FormatException('$linePath.chords: se requiere una lista.');
        }
        for (var chordIndex = 0; chordIndex < chords.length; chordIndex++) {
          final chordPath = '$linePath.chords[$chordIndex]';
          final chord = _object(chords[chordIndex], chordPath, {
            'symbol',
            'index',
          });
          _text(chord['symbol'], '$chordPath.symbol');
          final offset = chord['index'];
          if (offset is! int ||
              offset < 0 ||
              offset > text.length ||
              (offset > 0 &&
                  offset < text.length &&
                  _isHighSurrogate(text.codeUnitAt(offset - 1)) &&
                  _isLowSurrogate(text.codeUnitAt(offset)))) {
            throw FormatException('$chordPath.index: offset UTF-16 inválido.');
          }
        }
      }
    }
    final key = song['key'] as String;
    return ServiceDocumentItem(
      id: id,
      kind: kind,
      title: title,
      detail: '${sections.length} secciones${key.isEmpty ? '' : ' · $key'}',
    );
  }
  if (kind == 'SCRIPTURE') {
    final scripture = _object(value, path, {
      'reference',
      'version',
      'text',
      'source',
    });
    if (scripture.containsKey('source')) {
      _text(scripture['source'], '$path.source');
    }
    final reference = _text(scripture['reference'], '$path.reference');
    final version = _text(scripture['version'], '$path.version');
    _text(scripture['text'], '$path.text');
    return ServiceDocumentItem(
      id: id,
      kind: kind,
      title: reference,
      detail: version,
    );
  }
  final body = _object(value, path, {'title', 'body'});
  final title = _text(body['title'], '$path.title');
  _text(body['body'], '$path.body');
  return ServiceDocumentItem(id: id, kind: kind, title: title, detail: '');
}

Map<String, Object?> _object(Object? value, String path, Set<String> keys) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$path: se requiere un objeto.');
  }
  for (final key in value.keys) {
    if (!keys.contains(key)) {
      throw FormatException('$path.$key: campo desconocido.');
    }
  }
  return value;
}

String _text(Object? value, String path) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$path: se requiere texto no vacío.');
  }
  return value;
}

bool _isHighSurrogate(int value) => value >= 0xd800 && value <= 0xdbff;
bool _isLowSurrogate(int value) => value >= 0xdc00 && value <= 0xdfff;
