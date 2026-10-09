import 'dart:convert';

/// The local PublicContent 0.1 exchange document owned by LVM Service.
///
/// This is a file contract, not a public API or a publication signal.
final class PublicContent {
  const PublicContent({
    required this.generatedAt,
    required this.events,
    required this.sermons,
    required this.venues,
  });

  final DateTime generatedAt;
  final List<PublicEvent> events;
  final List<PublicSermon> sermons;
  final List<PublicVenue> venues;

  static PublicContent parseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('El archivo no contiene JSON válido.');
    }
    return parse(decoded);
  }

  static PublicContent parse(Object? value) {
    final object = _object(value, 'publicContent', {
      'schemaVersion',
      'generatedAt',
      'events',
      'sermons',
      'venues',
    });
    if (object['schemaVersion'] != '0.1') {
      throw const FormatException(
        'publicContent.schemaVersion: se requiere la versión 0.1.',
      );
    }
    return PublicContent(
      generatedAt: _timestamp(
        object['generatedAt'],
        'publicContent.generatedAt',
      ),
      events: _entries(
        object['events'],
        'publicContent.events',
        PublicEvent.parse,
        (event) => event.id,
      ),
      sermons: _entries(
        object['sermons'],
        'publicContent.sermons',
        PublicSermon.parse,
        (sermon) => sermon.id,
      ),
      venues: _entries(
        object['venues'],
        'publicContent.venues',
        PublicVenue.parse,
        (venue) => venue.id,
      ),
    );
  }
}

final class PublicEvent {
  const PublicEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.venue,
    required this.kind,
    required this.description,
  });

  final String id;
  final String title;
  final String date;
  final String time;
  final String venue;
  final String kind;
  final String description;

  static PublicEvent parse(Object? value, String path) {
    final item = _object(value, path, {
      'id',
      'title',
      'date',
      'time',
      'venue',
      'kind',
      'description',
    });
    final time = _text(item['time'], '$path.time');
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time)) {
      throw FormatException('$path.time: se requiere HH:mm.');
    }
    final kind = _text(item['kind'], '$path.kind');
    if (kind != 'culto' && kind != 'encuentro') {
      throw FormatException('$path.kind: se requiere culto o encuentro.');
    }
    return PublicEvent(
      id: _text(item['id'], '$path.id'),
      title: _text(item['title'], '$path.title'),
      date: _date(item['date'], '$path.date'),
      time: time,
      venue: _text(item['venue'], '$path.venue'),
      kind: kind,
      description: _text(item['description'], '$path.description'),
    );
  }
}

final class PublicSermon {
  const PublicSermon({
    required this.id,
    required this.title,
    required this.series,
    required this.speaker,
    required this.date,
    required this.duration,
    required this.summary,
  });

  final String id;
  final String title;
  final String series;
  final String speaker;
  final String date;
  final String duration;
  final String summary;

  static PublicSermon parse(Object? value, String path) {
    final item = _object(value, path, {
      'id',
      'title',
      'series',
      'speaker',
      'date',
      'duration',
      'summary',
    });
    return PublicSermon(
      id: _text(item['id'], '$path.id'),
      title: _text(item['title'], '$path.title'),
      series: _text(item['series'], '$path.series'),
      speaker: _text(item['speaker'], '$path.speaker'),
      date: _date(item['date'], '$path.date'),
      duration: _text(item['duration'], '$path.duration'),
      summary: _text(item['summary'], '$path.summary'),
    );
  }
}

final class PublicVenue {
  const PublicVenue({
    required this.id,
    required this.name,
    required this.zone,
    required this.address,
    required this.hours,
    required this.isMain,
  });

  final String id;
  final String name;
  final String zone;
  final String address;
  final String hours;
  final bool isMain;

  static PublicVenue parse(Object? value, String path) {
    final item = _object(value, path, {
      'id',
      'name',
      'zone',
      'address',
      'hours',
      'isMain',
    });
    if (item['isMain'] is! bool) {
      throw FormatException('$path.isMain: se requiere un booleano.');
    }
    return PublicVenue(
      id: _text(item['id'], '$path.id'),
      name: _text(item['name'], '$path.name'),
      zone: _text(item['zone'], '$path.zone'),
      address: _text(item['address'], '$path.address'),
      hours: _text(item['hours'], '$path.hours'),
      isMain: item['isMain'] as bool,
    );
  }
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

String _date(Object? value, String path) {
  final raw = _text(value, path);
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) throw FormatException('$path: se requiere YYYY-MM-DD.');
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final parsed = DateTime.utc(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw FormatException('$path: fecha inválida.');
  }
  return raw;
}

DateTime _timestamp(Object? value, String path) {
  final raw = _text(value, path);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$').hasMatch(raw)) {
    throw FormatException('$path: se requiere timestamp ISO UTC.');
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null || parsed.toUtc().toIso8601String() != raw) {
    throw FormatException('$path: timestamp inválido.');
  }
  return parsed;
}

List<T> _entries<T>(
  Object? value,
  String path,
  T Function(Object?, String) parse,
  String Function(T) idOf,
) {
  if (value is! List) throw FormatException('$path: se requiere una lista.');
  final ids = <String>{};
  final result = <T>[];
  for (var index = 0; index < value.length; index++) {
    final itemPath = '$path[$index]';
    final item = parse(value[index], itemPath);
    final id = idOf(item);
    if (!ids.add(id)) throw FormatException('$itemPath.id: ID duplicado.');
    result.add(item);
  }
  return List.unmodifiable(result);
}
